---@module "snacks"

require("features").add({
  "Enable fancy fuzzy finders",
  plugins = {
    {
      "folke/snacks.nvim",
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
        desc = "Buffer",
      },
      {
        "<leader>fc",
        function()
          Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
        end,
        desc = "Config File",
      },
      {
        "<leader>ff",
        function()
          Snacks.picker.files({ cwd = vim.fn.expand("%:p:h") })
        end,
        desc = "File (current buffer directory)",
      },
      {
        "<leader>fg",
        function()
          Snacks.picker.grep()
        end,
        desc = "Grep Files",
      },
      {
        "<leader>fG",
        function()
          Snacks.picker.git_files()
        end,
        desc = "Git File",
      },
      {
        "<leader>fl",
        function()
          Snacks.picker.lines()
        end,
        desc = "Line",
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
