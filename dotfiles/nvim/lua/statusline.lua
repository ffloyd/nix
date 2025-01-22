local features = require("features")

features.add({
  "Fancy global statusline",
  plugins = {
    {
      "nvim-lualine/lualine.nvim",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      opts = {
        options = {
          globalstatus = true,
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { { "filename", path = 1 } },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      },
    },
  },
})

features.add({
  "Show LSP status in the statusline",
  plugins = {
    {
      "linrongbin16/lsp-progress.nvim",
      opts = {},
    },
    {
      "nvim-lualine/lualine.nvim",
      opts = function(_, opts)
        table.insert(opts.sections.lualine_x, 1, function()
          return require("lsp-progress").progress()
        end)
      end,
    },
  },
  setup = function()
    -- listen lsp-progress event and refresh lualine
    vim.api.nvim_create_augroup("lualine_augroup", { clear = true })
    vim.api.nvim_create_autocmd("User", {
      group = "lualine_augroup",
      pattern = "LspProgressStatusUpdated",
      callback = require("lualine").refresh,
    })
  end,
})

features.add({
  "Show Copilot status in the statusline",
  plugins = {
    { "AndreM222/copilot-lualine" },
    {
      "nvim-lualine/lualine.nvim",
      opts = function(_, opts)
        table.insert(opts.sections.lualine_x, 2, {
          "copilot",
          show_colors = true,
          symbols = {
            status = {
              icons = {
                enabled = "",
                sleep = "", -- auto-trigger disabled
                disabled = "",
                warning = "",
                unknown = "",
              },
            },
          },
        })
      end,
    },
  },
})
