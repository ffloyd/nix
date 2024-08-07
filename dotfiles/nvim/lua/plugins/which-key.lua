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
      { "<leader>bd", "<cmd>bdelete<cr>", desc = "Delete Buffer" },
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
      { "<leader>pp", "<cmd>Telescope projects<cr>", desc = "List Projects" },

      { "<leader>t", group = "toggle" },
      { "<leader>tl", desc = "<cmd>set number<cr><cmd>set relativenumber<cr>" },
    })
  end,
}
