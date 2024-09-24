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
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "AndreM222/copilot-lualine",
      "gbprod/nord.nvim",
    },
    config = function()
      local palette = require("nord.colors").palette
      local darken = require("nord.utils").darken

      require("lualine").setup({
        options = {
          theme = "nord",
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { "filename" },
          lualine_x = {
            {
              "copilot",
              show_colors = true,
              symbols = {
                status = {
                  hl = {
                    enabled = palette.aurora.green,
                    sleep = palette.snow_storm.origin,
                    disabled = darken(palette.snow_storm.origin, 0.5, palette.polar_night.brightest),
                    warning = palette.aurora.yellow,
                    unknown = palette.aurora.red,
                  },
                },
                spinner_color = palette.snow_storm.brighter,
              },
            },
            "encoding",
            "fileformat",
            "filetype",
          },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { "filename" },
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {},
        },
      })
    end,
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
