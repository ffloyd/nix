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
      -- required by IEx strategy
      "akinsho/toggleterm.nvim",
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-elixir"),
        },
        -- default_strategy = "iex",
        consumers = {
          overseer = require("neotest.consumers.overseer"),
        },
        watch = {
          enabled = false,
        },
        running = {
          concurrent = false,
        },
        discovery = {
          enabled = false
        },
      })
    end,
  },
}
