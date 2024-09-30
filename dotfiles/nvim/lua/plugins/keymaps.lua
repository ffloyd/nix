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
    -- for 'require's in config function here
    "lewis6991/gitsigns.nvim",
    "nvim-neotest/neotest",
  },
  config = function()
    local wk = require("which-key")
    local gitsigns = require("gitsigns")
    local telescope = require("telescope.builtin")
    local telescope_utils = require("telescope.utils")
    local tabby = require("tabby")

    wk.setup({
      preset = "modern",
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

    local function rename_tab()
      local new_name = vim.fn.input("New name: ")
      tabby.tab_rename(new_name)
    end

    wk.add({
      { "<leader><leader>", "<cmd>Telescope find_files<cr>", desc = "Find file (pwd)" },

      { "<leader>a", group = "ai" },
      { "<leader>aA", "<cmd>TermExec cmd='ai' direction=tab<cr>", desc = "Open Aider in new tab" },

      { "<leader>b", group = "buffer" },
      { "<leader>bb", "<cmd>Telescope buffers<cr>", desc = "List buffers" },
      { "<leader>bc", "<cmd>cd %:p:h<cr><cmd>pwd<cr>", desc = "CD to buffer" },
      { "<leader>bk", "<cmd>bdelete<cr>", desc = "Kill buffer" },
      { "<leader>bn", "<cmd>bnext<cr>", desc = "Next buffer" },
      { "<leader>bp", "<cmd>bprev<cr>", desc = "Prev buffer" },

      { "<leader>c", group = "code" },
      {
        "<leader>cs",
        "<cmd>Trouble symbols toggle<cr>",
        desc = "Symbols",
      },
      {
        "<leader>cl",
        "<cmd>Trouble lsp toggle win.position=right<cr>",
        desc = "LSP definitions / references / ...",
      },

      { "<leader>f", group = "file" },
      { "<leader>fa", "<cmd>Telescope telescope-alternate alternate_file<cr>", desc = "Find alternate file" },
      {
        "<leader>ff",
        function()
          telescope.find_files({ cwd = telescope_utils.buffer_dir() })
        end,
        desc = "Find file (cwd)",
      },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Grep files" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Open recent file" },
      { "<leader>fm", "<cmd>RenameFile<cr>", desc = "Rename file" },

      { "<leader>g", group = "git" },
      -- navigation between hunks
      { "<leader>gv", gitsigns.preview_hunk, desc = "Preview hunk" },
      { "<leader>gn", gitsigns.next_hunk, desc = "Next hunk" },
      { "<leader>gp", gitsigns.prev_hunk, desc = "Prev hunk" },
      -- navigation between hunks (alternative)
      { "[g", gitsigns.prev_hunk, desc = "Prev git hunk" },
      { "]g", gitsigns.next_hunk, desc = "Next git hunk" },
      -- staging/unstaging/resetting hunks & lines
      { "<leader>gs", gitsigns.stage_hunk, desc = "Stage/unstage hunk", mode = "n" },
      {
        "<leader>gs",
        function()
          gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end,
        desc = "Stage/unstage lines",
        mode = "v",
      },
      { "<leader>gr", gitsigns.reset_hunk, desc = "Reset hunk", mode = "n" },
      {
        "<leader>gr",
        function()
          gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end,
        desc = "Reset lines",
        mode = "v",
      },
      { "<leader>gu", gitsigns.undo_stage_hunk, desc = "Undo stage/unstage hunk" },
      -- blaming
      { "<leader>gb", gitsigns.blame, desc = "Blame" },
      -- diffs
      { "<leader>gd", gitsigns.diffthis, desc = "Diff current file" },
      { "<leader>gD", "<cmd>DiffviewOpen<cr>", desc = "Diff all changes" },
      -- history explorer
      { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "History (branch)" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "History (file)" },
      -- NeoGit
      { "<leader>gg", "<cmd>Neogit<cr>", desc = "NeoGit" },

      { "<leader>p", group = "project" },

      { "<leader>r", group = "runner" },
      { "<leader>rr", "<cmd>OverseerRun<cr>", desc = "Run" },
      { "<leader>rt", "<cmd>OverseerToggle<cr>", desc = "Toggle task list" },
      { "<leader>rx", "<cmd>OverseerClearCache<cr>", desc = "Clear task cache" },
      { "<leader>ri", "<cmd>OverseerInfo<cr>", desc = "Tasks info" },

      { "<leader>t", group = "tabs" },
      { "<leader>tn", "<cmd>tabnext<cr>", desc = "Next tab" },
      { "<leader>tp", "<cmd>tabprev<cr>", desc = "Prev tab" },
      { "<leader>t ", "<cmd>tabnew<cr>", desc = "New tab" },
      { "<leader>tt", "<cmd>Tabby pick_window<cr>", desc = "Jump to window" },
      { "<leader>tr", rename_tab, desc = "Rename tab" },
      { "<leader>t>", "<cmd>+tabmove<cr>", desc = "Move tab to right" },
      { "<leader>t<", "<cmd>-tabmove<cr>", desc = "Move tab to left" },
      { "<leader>tk", "<cmd>tabclose<cr>", desc = "Kill tab" },
      { "<leader>to", "<cmd>tabonly<cr>", desc = "Kill other tab(s)" },

      { "<leader>T", group = "toggle" },
      -- line numbers
      { "<leader>Tl", toggle_line_numbers, desc = "Toggle line numbers" },
      { "<leader>TL", toggle_relative_line_numbers, desc = "Toggle relative line numbers" },
      -- Git things
      { "<leader>Tg", gitsigns.toggle_signs, desc = "Toggle Gitsigns" },
      { "<leader>Tb", gitsigns.toggle_current_line_blame, desc = "Toggle current line blame" },

      { "<leader>u", group = "utils" },
      -- undo tree
      { "<leader>uu", "<cmd>UndotreeToggle<cr>", desc = "Undo tree" },
      -- LSP
      { "<leader>ul", group = "LSP" },
      { "<leader>ull", "<cmd>LspInfo<cr>", desc = "LSP info" },
      { "<leader>ulL", "<cmd>LspLog<cr>", desc = "LSP log" },
      { "<leader>uls", "<cmd>LspStart<cr>", desc = "LSP start" },
      { "<leader>ulx", "<cmd>LspStop<cr>", desc = "LSP stop" },
      { "<leader>ulr", "<cmd>LspRestart<cr>", desc = "LSP restart" },
      { "<leader>uc", "<cmd>CmpStatus<cr>", desc = "nvim-cmp sources status" },
      -- notifications
      { "<leader>un", "<cmd>Telescope notify<cr>", desc = "List recent notifications" },

      { "<leader>x", group = "diagnostics" },
      {
        "<leader>xx",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics",
      },
      {
        "<leader>xX",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer diagnostics",
      },
      {
        "<leader>xl",
        "<cmd>Trouble loclist toggle<cr>",
        desc = "Location list",
      },
      {
        "<leader>xq",
        "<cmd>Trouble qflist toggle<cr>",
        desc = "Quickfix list",
      },
    })
  end,
}
