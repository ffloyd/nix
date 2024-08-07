-- Function to calculate a darker color from a hexadecimal RGB string
local function darken_color(hex_string, factor)
    local r = tonumber(hex_string:sub(2, 3), 16)
    local g = tonumber(hex_string:sub(4, 5), 16)
    local b = tonumber(hex_string:sub(6, 7), 16)

    -- Decrease RGB values proportionally based on luminance
    r = math.floor(factor * r)
    g = math.floor(factor * g)
    b = math.floor(factor * b)

    return string.format('#%02X%02X%02X', r, g, b)
end

return {
  "gbprod/nord.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("nord").setup({
      on_highlights = function(h, c)
        -- by default these colors have `fg` defined and it kills all syntax highlighting in diffs
        h.DiffAdd = { bg = darken_color(c.aurora.green, 0.4) } -- diff mode: Added line
        h.DiffChange = { bg = darken_color(c.aurora.yellow, 0.4) } --  diff mode: Changed line
        h.DiffDelete = { bg = darken_color(c.aurora.red, 0.4) } -- diff mode: Deleted line
        h.DiffText = { bg = darken_color(c.aurora.yellow, 0.5) } -- diff mode: Changed text within a changed line
      end,
    })
    vim.cmd.colorscheme("nord")
  end,
}
