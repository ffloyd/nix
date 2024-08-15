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

      vim.wo.foldmethod = 'expr'
      vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    end,
  },
}
