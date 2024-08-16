--
-- Custom keymaps and keymap's UX improvements.
--

local function toggle_line_numbers()
  if vim.wo.number then
    vim.wo.number = false
    vim.wo.relativenumber = false
  else
    vim.wo.number = true
    vim.wo.relativenumber = true
  end
end

local function toggle_relative_line_numbers()
  vim.wo.relativenumber = not vim.wo.relativenumber
end

return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 750
  end,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local wk = require("which-key")
    wk.add({
      { "<leader>a", group = "ai" },
      { "<leader>ae", "<cmd>ChatGPTEditWithInstructions<cr>", desc = "Edit with GPT" },
      { "<leader>ag", "<cmd>ChatGPT<cr>", desc = "Chat with GPT" },

      { "<leader>b", group = "buffer" },
      { "<leader>bb", "<cmd>Telescope buffers<cr>", desc = "List Buffers" },
      { "<leader>bc", "<cmd>cd %:p:h<cr><cmd>pwd<cr>", desc = "CD to Buffer" },
      { "<leader>bk", "<cmd>bdelete<cr>", desc = "Kill Buffer" },
      { "<leader>bn", "<cmd>bnext<cr>", desc = "Next Buffer" },
      { "<leader>bp", "<cmd>bprev<cr>", desc = "Prev Buffer" },

      { "<leader>f", group = "file" },
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find File" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Grep Files" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Open Recent File" },

      { "<leader>g", group = "git" },
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview" },
      { "<leader>gg", "<cmd>Neogit<cr>", desc = "NeoGit" },

      { "<leader>p", group = "project" },

      { "<leader>t", group = "toggle" },
      { "<leader>tl", toggle_line_numbers, desc = "Toggle Line Numbers" },
      { "<leader>tL", toggle_relative_line_numbers, desc = "Toggle Relative Line Numbers" },
    })
  end,
}
