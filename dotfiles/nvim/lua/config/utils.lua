---@class Feature
---@field name string The name of the feature
---@field plugins LazyPluginSpec[]|nil An optional array of lazy.nvim plugin specifications
---@field setup function|nil An optional setup function to be called after loading plugins

local M = {
    -- Use a table with feature names as keys to prevent duplicates
    features = {},
}

---Define new features and add them to the global features list
---@param new_features Feature[] An array of Feature objects to be defined
---@return nil
function M.define_features(new_features)
    for _, feature in ipairs(new_features) do
        if type(feature.name) ~= "string" then
            error("Feature must have a name")
        end

        if feature.plugins and type(feature.plugins) ~= "table" then
            error(string.format("Invalid plugins definition for feature '%s'", feature.name))
        end

        if feature.setup and type(feature.setup) ~= "function" then
            error(string.format("Invalid setup definition for feature '%s'", feature.name))
        end

        -- Store feature by name to prevent duplicates
        M.features[feature.name] = feature
    end
end

---Load all defined features
---@return nil
function M.load_features()
    local all_plugins = {}

    -- Collect all plugin specs
    for _, feature in pairs(M.features) do
        if feature.plugins then
            vim.list_extend(all_plugins, feature.plugins)
        end
    end

    -- Setup all plugins at once
    if #all_plugins > 0 then
        require("lazy").setup(all_plugins)
    end

    -- Execute setup functions for all features
    for name, feature in pairs(M.features) do
        if feature.setup then
            local ok, err = pcall(feature.setup)
            if not ok then
                vim.notify(
                    string.format("Failed to run setup for feature '%s': %s", name, err),
                    vim.log.levels.ERROR
                )
            end
        end
    end
end

return M
