-- A small wrapper around lazy.nvim which allows configuring features rather than plugins.
--
-- By default, lazy.nvim has the following disadvantages:
--
-- 1) It allows calling the `setup` function only once.
--    In the scope of a single file, you cannot mix plugin configurations and Lua code which is inconvenient.
--
-- 2) It does not provide an easy mechanism to specify code that should be executed after all plugins are loaded.
--
-- In response to the above issues, this module introduces the concept of a feature.
-- A feature is defined by:
-- * title   - a string that describes the feature
-- * plugins - an optional list of lazy.nvim plugin specs
-- * setup   - a function that will be called after all plugins (including those from other features) are loaded (optional)
-- * id      - an optional unique identifier for the feature
-- * after   - an optional list of other feature IDs. This feature will be loaded only after all features mentioned in this list loaded.

---@module "lazy"

--- A feature definition.
---@class Feature
---@field [1] string                    The title of the feature (name)
---@field id string|nil                 Unique identifier for the feature
---@field plugins LazyPluginSpec[]|nil  Optional array of lazy.nvim plugin specifications
---@field setup function|nil            Optional setup function to be called after loading plugins
---@field after string[]|nil            Optional list of feature ids that should be loaded before this feature

---@type Feature[]
local defined_features = {}
local used_ids = {}
local used_titles = {}

local M = {}

--- Add a new feature to the global features map.
--- If `id` is not provided, uses title as an id.
---@param feature Feature A Feature object to be added
function M.add(feature)
  if type(feature[1]) ~= "string" then
    vim.notify(string.format(
      "[features.add] Title must be a string, got %s (value: %s). Feature will not be loaded.",
      type(feature[1]),
      vim.inspect(feature[1])
    ), vim.log.levels.ERROR)
    return
  end

  if feature.after and type(feature.after) ~= "table" then
    vim.notify(string.format(
      "[features.add] Feature '%s': 'after' must be a table, got %s (value: %s). Feature will not be loaded.",
      feature[1],
      type(feature.after),
      vim.inspect(feature.after)
    ), vim.log.levels.ERROR)
    return
  end

  if feature.setup and type(feature.setup) ~= "function" then
    vim.notify(string.format(
      "[features.add] Feature '%s': 'setup' must be a function, got %s. Feature will not be loaded.",
      feature[1],
      type(feature.setup)
    ), vim.log.levels.ERROR)
    return
  end

  if used_ids[feature.id] then
    vim.notify(string.format(
      "[features.add] Feature '%s': ID '%s' is already used by another feature. Feature will not be loaded.",
      feature[1],
      feature.id
    ), vim.log.levels.ERROR)
    return
  end

  if used_titles[feature[1]] then
    vim.notify(string.format(
      "[features.add] Feature title '%s' is already used by another feature. Feature will not be loaded.",
      feature[1]
    ), vim.log.levels.ERROR)
    return
  end

  feature.after = feature.after or {}

  if feature.id ~= nil then
    used_ids[feature.id] = true
  end

  used_titles[feature[1]] = true
  defined_features[#defined_features + 1] = feature
end

local function has_all(list, elements)
  for _, element in ipairs(elements) do
    if not vim.list_contains(list, element) then
      return false
    end
  end

  return true
end

--- @return Feature[] Ordered list of features with respect to `after` constraint
local function order_features()
  local result = {}
  local added_ids = {}

  --- @type table<string, Feature>
  local postponed = {}

  local function key(feature)
    return feature.id or feature[1]
  end

  local function add_to_result(feature)
    result[#result + 1] = feature
    if feature.id ~= nil then
      added_ids[#added_ids + 1] = feature.id
    end
  end

  local function can_be_added(feature)
    return has_all(added_ids, feature.after)
  end

  local function postpone(feature)
    postponed[key(feature)] = feature
  end

  local function extract_postponed_that_can_be_added()
    local extracted = {}

    for _, feature in pairs(postponed) do
      if can_be_added(feature) then
        extracted[#extracted + 1] = feature
      end
    end

    for _, feature in ipairs(extracted) do
      postponed[key(feature)] = nil
    end

    return extracted
  end

  for _, feature in ipairs(defined_features) do
    if can_be_added(feature) then
      add_to_result(feature)
    else
      postpone(feature)
    end

    for _, satisfied_feature in ipairs(extract_postponed_that_can_be_added()) do
      add_to_result(satisfied_feature)
    end
  end

  if next(postponed) ~= nil then
    local names_with_reqs = {}
    for _, feature in pairs(postponed) do
      names_with_reqs[#names_with_reqs + 1] = "Feature \"" ..
          feature[1] .. "\" requires " .. table.concat(feature.after, ", ") .. "."
    end

    table.sort(names_with_reqs)
    table.sort(added_ids)

    vim.notify(
      "The following features have unsatisfied dependencies or form dependency cycles:\n\n" ..
      table.concat(names_with_reqs, "\n") ..
      "\n\nPlease check the `after` field of the features.\n" ..
      "The sorted list of added IDs:\n" ..
      table.concat(added_ids, ", ") ..
      "\nThe mentioned features will be loaded anyway.",
      vim.log.levels.WARN
    )

    for _, feature in pairs(postponed) do
      add_to_result(feature)
    end
  end

  return result
end

---@param features Feature[]
---@return LazyPluginSpec[]
local function lazy_specs(features)
  local specs = {}

  for _, feature in ipairs(features) do
    if feature.plugins then
      for _, plugin in ipairs(feature.plugins) do
        specs[#specs + 1] = plugin
      end
    end
  end

  return specs
end

---Load all features
---It will setup all plugins using lazy.nvim and execute setup functions for all features afterwards.
---@return nil
function M.load()
  local ordered_features = order_features()

  require("lazy").setup(lazy_specs(ordered_features))

  for _, feature in ipairs(ordered_features) do
    if feature.setup then
      feature.setup()
    end
  end
end

function M.report_order()
  local ordered_features = order_features()

  local names = {}
  for _, feature in ipairs(ordered_features) do
    if feature.id then
      names[#names + 1] = feature[1] .. " (ID: " .. feature.id .. ")"
    else
      names[#names + 1] = feature[1]
    end
  end

  local msg = "The features will be loaded in the following order:\n" .. table.concat(names, "\n")

  vim.notify(msg, vim.log.levels.INFO)
end

return M
