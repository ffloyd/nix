--
-- Run tests, jump to test files, etc
--
return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      -- adapters:
      "jfpedroza/neotest-elixir",
      -- consumers
      "stevearc/overseer.nvim",
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-elixir"),
        },
        consumers = {
          overseer = require("neotest.consumers.overseer"),
        },
        watch = {
          enabled = false,
        }
      })
    end,
  },
}
