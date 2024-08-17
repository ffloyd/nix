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

    wk.setup({
      preset = "modern"
    })

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
      -- navigation between hunks
      { "<leader>gv", gitsigns.preview_hunk, desc = "Preview hunk" },
      { "<leader>gn", gitsigns.next_hunk, desc = "Next hunk" },
      { "<leader>gp", gitsigns.prev_hunk, desc = "Prev hunk" },
      -- staging/unstaging/resetting hunks & lines
      { "<leader>gs", gitsigns.stage_hunk, desc = "Stage/unstage hunk", mode = "n" },
      { "<leader>gs", function() gitsigns.stage_hunk({vim.fn.line('.'), vim.fn.line('v')}) end, desc = "Stage/unstage lines", mode = "v" },
      { "<leader>gr", gitsigns.reset_hunk, desc = "Reset hunk", mode = "n" },
      { "<leader>gr", function() gitsigns.reset_hunk({vim.fn.line('.'), vim.fn.line('v')}) end, desc = "Reset lines", mode = "v" },
      { "<leader>gu", gitsigns.undo_stage_hunk, desc = "Undo stage/unstage hunk" },
      -- blaming
      { "<leader>gb", gitsigns.blame, desc = "Blame" },
      -- diffs
      { "<leader>gd", gitsigns.diffthis, desc = "Diff current file" },
      { "<leader>gD", "<cmd>DiffviewOpen<cr>", desc = "Diff all changes" },
      -- NeoGit
      { "<leader>gg", "<cmd>Neogit<cr>", desc = "NeoGit" },

      { "<leader>p", group = "project" },

      { "<leader>t", group = "toggle" },
      -- line numbers
      { "<leader>tl", toggle_line_numbers, desc = "Toggle line numbers" },
      { "<leader>tL", toggle_relative_line_numbers, desc = "Toggle relative line numbers" },
      -- Git things
      { "<leader>tb", gitsigns.toggle_signs, desc = "Toggle Gitsigns"},
      { "<leader>tb", gitsigns.toggle_current_line_blame, desc = "Toggle current line blame"},

      { "<leader>u", group = "utils" },
      { "<leader>uu", "<cmd>UndotreeToggle<cr>", desc = "Undo tree" }
    })
  end,
}
