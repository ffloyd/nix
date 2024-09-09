-- adjust TAB behavior
vim.o.expandtab = true
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.shiftwidth = 2

-- show relative line numbers by default
vim.o.number = true
vim.o.relativenumber = true

-- I do not need swap files
vim.o.swapfile = false

-- open files with all folds open
vim.o.foldlevelstart = 99

-- enable spell suggest
vim.opt.spell = true
vim.opt.spelllang = { "en_us" }

-- leader key setup
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- More place for signs
-- see: https://github.com/lewis6991/gitsigns.nvim/issues/1102
-- I set 3 because sometimes it can be 2 for GitSigns and 1 for NeoTest
vim.o.signcolumn = "auto:1-3"

-- use system clipboard by default
vim.opt.clipboard:append("unnamedplus")

-- required by plugins like nvim-notify
vim.opt.termguicolors = true
