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

          -- definitions from another Nord port: https://github.com/shaunsingh/nord.nvim/blob/master/lua/nord/theme.lua#L695
          h.RainbowDelimiterRed = { fg = palette.aurora.red }
          h.RainbowDelimiterYellow = { fg = palette.aurora.yellow }
          h.RainbowDelimiterBlue = { fg = palette.frost.artic_water }
          h.RainbowDelimiterOrange = { fg = palette.aurora.orange }
          h.RainbowDelimiterGreen = { fg = palette.aurora.green }
          h.RainbowDelimiterViolet = { fg = palette.aurora.purple }
          h.RainbowDelimiterCyan = { fg = palette.frost.ice }
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
  {
    "nanozuki/tabby.nvim",
    init = function()
      vim.opt.sessionoptions = "curdir,folds,globals,help,tabpages,terminal,winsize"
    end,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("tabby").setup({
        preset = "active_wins_at_tail",
        option = {
          nerdfont = true,
          lualine_theme = "nord",
        },
      })
    end,
  },
}
