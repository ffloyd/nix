--
-- Git tooling
--
return {
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",         -- required
      "sindrets/diffview.nvim",        -- optional - Diff integration

      -- Only one of these is needed, not both.
      "nvim-telescope/telescope.nvim", -- optional
      -- "ibhagwan/fzf-lua",              -- optional
    },
    config = true
  },
  {
    "sindrets/diffview.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons"
    },
    config = function()
      require("diffview").setup({
        enhanced_diff_hl = true,
      })

      -- fancy diff for deleted lines
      vim.opt.fillchars:append { diff = "╱" }
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    init = function()
      -- see: https://github.com/lewis6991/gitsigns.nvim/issues/1102
      vim.o.signcolumn = "auto:1-2"
    end,
    config = true
  }
}
