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
    "linrongbin16/lsp-progress.nvim",
    config = function()
      require("lsp-progress").setup({})
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    init = function()
      vim.o.laststatus = 3
    end,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "AndreM222/copilot-lualine",
      "gbprod/nord.nvim",
      "linrongbin16/lsp-progress.nvim",
    },
    config = function()
      local palette = require("nord.colors").palette
      local darken = require("nord.utils").darken

      -- lsp-progress setup (https://github.com/linrongbin16/lsp-progress.nvim?tab=readme-ov-file#lualinenvim)
      vim.api.nvim_create_augroup("lualine_augroup", { clear = true })
      vim.api.nvim_create_autocmd("User", {
        group = "lualine_augroup",
        pattern = "LspProgressStatusUpdated",
        callback = require("lualine").refresh,
      })

      require("lualine").setup({
        options = {
          theme = "nord",
          globalstatus = true,
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { "filename" },
          lualine_x = {
            -- we need function here to avoid lazy loading issues
            function()
              return require("lsp-progress").progress()
            end,
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
    "b0o/incline.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "gbprod/nord.nvim",
    },
    config = function()
      local devicons = require("nvim-web-devicons")
      local palette = require("nord.colors").palette

      require("incline").setup({
        window = {
          padding = 0,
          margin = { horizontal = 0 },
        },
        render = function(props)
          local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
          if filename == "" then
            filename = "[No Name]"
          end
          local ft_icon, ft_color = devicons.get_icon_color(filename)
          local modified = vim.bo[props.buf].modified
          return {
            ft_icon and { " ", ft_icon, " ", guifg = ft_color } or "",
            " ",
            { filename, gui = modified and "bold,italic" or "bold" },
            " ",
            guibg = palette.polar_night.bright,
          }
        end,
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
        preset = "tab_only",
        option = {
          nerdfont = true,
          lualine_theme = "nord",
        },
      })
    end,
  },
}
