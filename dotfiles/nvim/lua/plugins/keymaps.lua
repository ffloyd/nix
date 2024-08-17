--
-- Custom keymaps and keymap's UX improvements.
--

return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 750
  end,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "lewis6991/gitsigns.nvim"
  },
  config = function()
    local wk = require("which-key")
    local gitsigns = require("gitsigns")

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

    wk.add({
      { "<leader>a", group = "ai" },
      { "<leader>ae", "<cmd>ChatGPTEditWithInstructions<cr>", desc = "Edit with GPT" },
      { "<leader>ag", "<cmd>ChatGPT<cr>", desc = "Chat with GPT" },

      { "<leader>b", group = "buffer" },
      { "<leader>bb", "<cmd>Telescope buffers<cr>", desc = "List buffers" },
      { "<leader>bc", "<cmd>cd %:p:h<cr><cmd>pwd<cr>", desc = "CD to buffer" },
      { "<leader>bk", "<cmd>bdelete<cr>", desc = "Kill buffer" },
      { "<leader>bn", "<cmd>bnext<cr>", desc = "Next buffer" },
      { "<leader>bp", "<cmd>bprev<cr>", desc = "Prev buffer" },

      { "<leader>f", group = "file" },
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find file" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Grep files" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Open recent file" },

      { "<leader>g", group = "git" },
      { "<leader>gb", gitsigns.blame, desc = "Blame" },
      { "<leader>gd", gitsigns.diffthis, desc = "Diff Current File" },
      { "<leader>gD", "<cmd>DiffviewOpen<cr>", desc = "Diff All" },
      { "<leader>gg", "<cmd>Neogit<cr>", desc = "NeoGit" },
      { "<leader>gs", gitsigns.stage_hunk, desc = "Stage/unstage hunk", mode = "n" },
      { "<leader>gs", function() gitsigns.stage_hunk({vim.fn.line('.'), vim.fn.line('v')}) end, desc = "Stage/unstage lines", mode = "v" },
      { "<leader>gr", gitsigns.reset_hunk, desc = "Reset hunk", mode = "n" },
      { "<leader>gr", function() gitsigns.reset_hunk({vim.fn.line('.'), vim.fn.line('v')}) end, desc = "Reset lines", mode = "v" },
      { "<leader>gu", gitsigns.undo_stage_hunk, desc = "Undo stage/unstage hunk", mode = "n" },
      { "<leader>gn", gitsigns.next_hunk, desc = "Next hunk" },
      { "<leader>gp", gitsigns.prev_hunk, desc = "Prev Hunk" },
      { "<leader>gv", gitsigns.preview_hunk, desc = "Preview Hunk" },

      { "<leader>p", group = "project" },

      { "<leader>t", group = "toggle" },
      { "<leader>tb", gitsigns.toggle_signs, desc = "Toggle Gitsigns"},
      { "<leader>tl", toggle_line_numbers, desc = "Toggle line numbers" },
      { "<leader>tL", toggle_relative_line_numbers, desc = "Toggle relative line numbers" },
      { "<leader>tb", gitsigns.toggle_current_line_blame, desc = "Toggle current line blame"}
    })
  end,
}
