--
-- Themes, general look & feel, global UI improvements
--

return {
  {
    "gbprod/nord.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      local utils = require("nord.utils")
      local colors = require("nord.colors")

      local bg = utils.make_global_bg()
      local palette = colors.palette

      require("nord").setup({
        on_highlights = function(h, _)
          -- by default these colors have `fg` defined and it kills all syntax highlighting in diffs
          h.DiffAdd = { bg = utils.darken(palette.aurora.green, 0.2, bg) } -- diff mode: Added line
          h.DiffChange = { bg = utils.darken(palette.aurora.yellow, 0.2, bg) } --  diff mode: Changed line
          h.DiffDelete = { bg = utils.darken(palette.aurora.red, 0.2, bg) } -- diff mode: Deleted line
          h.DiffText = { bg = utils.darken(palette.aurora.yellow, 0.3, bg) } -- diff mode: Changed text within a changed line

        end,
      })
      vim.cmd.colorscheme("nord")
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme = "nord",
      },
    },
  },
  {
    "stevearc/dressing.nvim",
    opts = {},
  },
  {
    "rcarriga/nvim-notify",
    config = function()
      vim.notify = require("notify")
    end,
  },
}
