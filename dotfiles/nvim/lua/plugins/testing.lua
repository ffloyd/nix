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
      "jfpedroza/neotest-elixir"
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-elixir"),
        }
      })
    end
  }
}