--
-- Adjustments to core editing experience.
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
      vim.o.foldmethod = "expr"
      vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    end,
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true,
    -- use opts = {} for passing setup options
    -- this is equivalent to setup({}) function
    --
    -- TODO: check for integrations in README, especially nvim-cmp
  },
  {
    -- like subword-mode for EMACS
    "chrisgrieser/nvim-spider",
    keys = {
      {
        "w",
        "<cmd>lua require('spider').motion('w')<CR>",
        mode = { "n", "o", "x" },
      },
      {
        "e",
        "<cmd>lua require('spider').motion('e')<CR>",
        mode = { "n", "o", "x" },
      },
      {
        "b",
        "<cmd>lua require('spider').motion('b')<CR>",
        mode = { "n", "o", "x" },
      },
    },
  },
  {
    "HiPhish/rainbow-delimiters.nvim",
    config = function()
      local rainbow_delimiters = require("rainbow-delimiters")
      require("rainbow-delimiters.setup").setup({
        strategy = {
          [""] = rainbow_delimiters.strategy["local"],
        },
      })
    end,
  },
  {
    "mbbill/undotree",
  },
  {
    "fladson/vim-kitty",
  },
  {
    "MagicDuck/grug-far.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      local gf = require("grug-far")
      gf.setup({})

      local function search_word_ripgrep()
        gf.open({ prefills = { search = vim.fn.expand("<cword>") }, engine = "ripgrep" })
      end

      local function search_file_ripgrep()
        gf.open({ prefills = { paths = vim.fn.expand("%") }, engine = "ripgrep" })
      end

      local function search_file_astgrep()
        gf.open({ prefills = { paths = vim.fn.expand("%") }, engine = "astgrep" })
      end

      require("which-key").add({
        { "<leader>s", group = "search" },
        { "<leader>sp", "<cmd>GrugFar ripgrep<cr>", desc = "Search in project (ripgrep)" },
        { "<leader>sP", "<cmd>GrugFar astgrep<cr>", desc = "Search in project (ast-grep)" },
        { "<leader>sw", search_word_ripgrep, desc = "Search in project (ripgrep)" },
        { "<leader>sf", search_file_ripgrep, desc = "Search in file (ripgrep)" },
        { "<leader>sF", search_file_astgrep, desc = "Search in file (ast-grep)" },
      })
    end,
  },
}
