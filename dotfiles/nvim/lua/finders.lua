---@module "snacks"

require("features").add({
  "Enable fancy fuzzy finders",
  plugins = {
    {
      "folke/snacks.nvim",
      opts = function(_, opts)
        ---@type snacks.picker.Config
        opts.picker = {}
      end,
    },
  },
  setup = function()
    require("which-key").add({
      -- Top-level finders
      {
        "<leader>fb",
        function()
          Snacks.picker.buffers()
        end,
        desc = "Buffers",
      },
      {
        "<leader>fc",
        function()
          Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
        end,
        desc = "Find Config File",
      },
      {
        "<leader>ff",
        function()
          Snacks.picker.files()
        end,
        desc = "Find Files",
      },
      {
        "<leader>fg",
        function()
          Snacks.picker.git_files()
        end,
        desc = "Find Git Files",
      },
      {
        "<leader>fr",
        function()
          Snacks.picker.recent()
        end,
        desc = "Recent",
      },
    })
  end,
})

