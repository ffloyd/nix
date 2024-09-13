--
-- Navigation between many types of things
--
return {
  { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  {
    "otavioschwanck/telescope-alternate",
    config = function()
      require("telescope-alternate").setup({
        mappings = {
          -- Elixir
          { "lib/(.*).ex", {
            { "test/[1]_test.exs", "Test" },
          } },
          { "test/(.*)_test.exs", {
            { "lib/[1].ex", "Implementation" },
          } },
        },
      })
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      -- extensions
      "nvim-telescope/telescope-fzf-native.nvim",
      "otavioschwanck/telescope-alternate",
    },
    config = function()
      local telescope = require("telescope")

      telescope.load_extension("fzf")
      telescope.load_extension("telescope-alternate")
    end,
  },
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    config = function()
      require("trouble").setup({
        win = {
          size = 60,
        },
      })
    end,
  },
}
