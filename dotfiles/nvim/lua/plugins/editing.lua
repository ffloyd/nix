--
-- Adjustments to core editing expirience.
--
return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      local config = require("nvim-treesitter.configs")

      config.setup({
        auto_install = false,
        highlight = { enable = true },
        indent = { enable = true },
      })

      -- use treesitter for folding by default
      vim.o.foldmethod = 'expr'
      vim.o.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    end,
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true
    -- use opts = {} for passing setup options
    -- this is equalent to setup({}) function
    -- 
    -- TODO: check for integrations in README, especially nvim-cmp
  }
}
