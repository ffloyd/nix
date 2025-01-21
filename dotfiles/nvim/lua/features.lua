-- A small wrapper aroung lazy.nvim which allows configuring features rather than plugins.
--
-- By default lazy.nvim has the following disadventages:
--
-- 1) Tt allows call `setup` function only once.
-- So I cannot write some plugin configs, than generic Lua code, than another plugin configs.
--
-- 2) It does not allow easily specify some code that should be executed after all plugins are loaded.
--
-- In response to mentioned problems this module introduces concept of a feature.
-- Feature defined by:
-- * title - a string that describes the feature
-- * plugins - a list of lazy.nvim plugin specs
-- * setup - a function that will be called after all plugins (including plugins from other features) are loaded

---@module "lazy"

---@class Feature
---@field [1] string The name of the feature
---@field plugins LazyPluginSpec[]|nil An optional array of lazy.nvim plugin specifications
---@field setup function|nil An optional setup function to be called after loading plugins

local M = {
  ---@type Feature[]
  features = {},
}

---Add a new feature to the global features list
---@param feature Feature A Feature object to be added
---@return nil
function M.add(feature)
  M.features[#M.features + 1] = feature
  return nil
end

---Return all lazy.nvim plugin specs from all features
---@return LazyPluginSpec[]
function M.lazy_specs()
  local lazy_specs = {}

  for _, feature in pairs(M.features) do
    if feature.plugins then
      for _, plugin in pairs(feature.plugins) do
        lazy_specs[#lazy_specs + 1] = plugin
      end
    end
  end

  return lazy_specs
end

---Load all features
---It will setup all plugins using lazy.nvim and execute setup functions for all features afterwards.
---@return nil
function M.load()
  require("lazy").setup(M.lazy_specs())

  for _, feature in pairs(M.features) do
    if feature.setup then
      feature.setup()
    end
  end

  return nil
end

return M
