-- adjust TAB behaviour
vim.o.expandtab = true
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.shiftwidth = 2

-- I do not need swapfiles
vim.o.swapfile = false

-- open files with all folds open
vim.o.foldlevelstart = 99

-- leader key setup
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- More place for signs
-- see: https://github.com/lewis6991/gitsigns.nvim/issues/1102
-- I set 3 because sometimes it can be 2 for Gitsigns and 1 for Neotest
vim.o.signcolumn = "auto:1-3"

-- use system clipboard by default
vim.opt.clipboard:append("unnamedplus")

-- required by plugins like nvim-notify
vim.opt.termguicolors = true
