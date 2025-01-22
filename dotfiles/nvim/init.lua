-- This configuration is a slightly different than the most other configurations.
-- Instead of trying to organize everything in a single file,
-- or splitting it into multiple files by categories,
-- or organize by plugins or plugin groups,
-- this configuration is gave up on such approaches.
--
-- Instead, it's a single file that has no predefined structure.
-- But when some part of it grows too much,
-- it's extracted into a separate file and required here.
--
-- Other way to think about it is "folding-driven approach":
-- when you constantly want to fold some big chunk of your configuration -
-- extract it into a separate file.
--
-- Motivation behind such idea is that it's not possible to create a perfect organization.
-- Often some block of configuration is related to multiple plugins or multiple categories.
-- And it's often hard to decide where to put it.
-- And such decisions by nature are frustrating and consume both time and energy.
-- And we don't really rely on strict organization that much.
-- We usually rely more on project-wide search.
-- So, why spend time on something that doesn't bring much value, but definitely brings suffering?

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- use features-centric approach instead of plugin-centric
local features = require("features")

features.add({
  "Use a colorscheme that inspired by the Kanagawa wave",
  plugins = {
    {
      "rebelot/kanagawa.nvim",
      name = "kanagawa",
      priority = 1000,
      opts = {
        colors = {
          theme = {
            all = {
              ui = {
                -- disable separate fringe background
                bg_gutter = "none",
              },
            },
          },
        },
      },
    },
  },
  setup = function()
    vim.cmd.colorscheme("kanagawa-wave")
  end,
})

features.add({
  "Show available keybindings in a popup as you type",
  plugins = {
    {
      "folke/which-key.nvim",
      event = "VeryLazy",
      dependencies = {
        "nvim-tree/nvim-web-devicons",
      },
      opts = {
        preset = "modern",
        delay = 500,
      },
    },
  },
})

features.add({
  "Top-level leader keymap groups",
  setup = function()
    require("which-key").add({
      { "<leader>a", group = "Apps/AI" },
      { "<leader>b", group = "Buffer" },
      { "<leader>e", group = "Editor Helpers" },
      { "<leader>g", group = "Git/VCS" },
      { "<leader>f", group = "Finders" },
      { "<leader>s", group = "Search/Replace" },
      { "<leader>T", group = "Tabs" },
      { "<leader>t", group = "Toggle" },
      { "<leader>u", group = "Utils" },
      { "<leader>x", group = "eXplore" },
      { "<leader>?", group = "Help" },
    })
  end,
})

features.add({
  "Enable tree-sitter usage for all supported syntaxes",
  plugins = {
    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      config = function()
        local config = require("nvim-treesitter.configs")

        ---@diagnostic disable-next-line: missing-fields
        config.setup({
          ensure_installed = "all",
          auto_install = false,
          highlight = { enable = true },
          incremental_selection = { enable = true },
          indent = { enable = true },
        })

        -- also use for folding
        vim.o.foldmethod = "expr"
        vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
      end,
    },
  },
})

features.add({
  "2-space autoindentation by default",
  setup = function()
    vim.o.softtabstop = 2
    vim.o.shiftwidth = 2
    vim.o.expandtab = true
  end,
})

features.add({
  "Fetch default configurations for LSP servers (with respect to blink.cmp)",
  plugins = {
    {
      "neovim/nvim-lspconfig",
      dependencies = { "saghen/blink.cmp" },
      config = function()
        local lspconfig = require("lspconfig")
        local capabilities = require("blink-cmp").get_lsp_capabilities()

        lspconfig.dockerls.setup({ capabilities = capabilities })
        lspconfig.lua_ls.setup({ capabilities = capabilities })
        lspconfig.gopls.setup({ capabilities = capabilities })
        lspconfig.lexical.setup({
          cmd = { "lexical" },
          capabilities = capabilities,
        })
        lspconfig.nixd.setup({ capabilities = capabilities })
        lspconfig.terraformls.setup({ capabilities = capabilities })
        lspconfig.ts_ls.setup({ capabilities = capabilities })
      end,
    },
  },
})

features.add({
  "Improve LSP for NeoVim/LUA development",
  plugins = {
    {
      "folke/lazydev.nvim",
      ft = "lua",
      opts = {
        library = {
          -- Only load luvit types when the `vim.uv` word is found
          { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        },
      },
    },
  },
})

features.add({
  "Autocompletion with Blink",
  plugins = {
    {
      "saghen/blink.cmp",
      dependencies = {
        "rafamadriz/friendly-snippets",
      },
      version = "*",
      ---@module "blink-cmp"
      ---@type blink.cmp.Config
      opts = {
        keymap = { preset = "super-tab" },
        appearance = {
          use_nvim_cmp_as_default = true,
          nerd_font_variant = "mono",
        },
        sources = {
          default = { "lsp", "path", "snippets", "buffer" },
          providers = {},
        },
      },
    },
  },
})

features.add({
  "LazyDev <-> Blink integration",
  plugins = {
    {
      "saghen/blink.cmp",
      dependencies = "folke/lazydev.nvim",
      opts = function(_, opts)
        table.insert(opts.sources.default, 1, "lazydev")

        opts.sources.providers.lazydev = {
          name = "LazyDev",
          module = "lazydev.integrations.blink",
          -- make lazydev completions top priority (see `:h blink.cmp`)
          score_offset = 100,
        }
      end,
    },
  },
})

features.add({
  "Enable Snacks.nvim",
  plugins = {
    {
      "folke/snacks.nvim",
      priority = 1000,
      lazy = false,
      opts = {},
    },
  },
})
---@module "snacks"

features.add({
  "Fancy dashboard with Snacks",
  plugins = {
    {
      "folke/snacks.nvim",
      opts = function(_, opts)
        opts.dashboard = {
          example = "advanced",
        }
      end,
    },
  },
})

features.add({
  "Better UI elements from Snacks",
  plugins = {
    {
      "folke/snacks.nvim",
      opts = function(_, opts)
        opts.statuscolumn = {
          enabled = true,
          folds = {
            open = true,
            git_hl = true,
          },
        }
        opts.input = { enabled = true }
        opts.notifier = { enabled = true }
      end,
    },
  },
})

require("finders")

features.add({
  "Github Copilot integration",
  plugins = {
    {
      "zbirenbaum/copilot.lua",
      opts = {
        copilot_node_command = vim.fn.expand("$HOME") .. "/.copilot-node/node",
        suggestion = {
          enabled = true,
          auto_trigger = true,
          keymap = {
            accept = "<M-S-l>",
            accept_line = "<M-l>",
          },
        },
        panel = { enabled = false },
      },
    },
  },
})

features.add({
  "Discover top-level keybindings",
  setup = function()
    require("which-key").add({
      {
        "<leader>?/",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
      {
        "<leader>??",
        function()
          require("which-key").show({ global = true })
        end,
        desc = "Global Keymaps (which-key)",
      },
    })
  end,
})

features.add({
  "Search lines by `C-SPC C-SPC` and files by `SPC SPC`",
  setup = function()
    require("which-key").add({
      {
        "<C-Space><C-Space>",
        function()
          Snacks.picker.lines()
        end,
        desc = "Find Line",
      },
      {
        "<Space><Space>",
        function()
          Snacks.picker.files()
        end,
        desc = "Find File",
      },
    })
  end,
})

features.add({
  "Search commands by <leader>:",
  setup = function()
    require("which-key").add({
      {
        "<leader>:",
        function()
          Snacks.picker.command_history()
        end,
        desc = "Command History",
      },
    })
  end,
})

features.add({
  "Use Snacks.debug",
  setup = function()
    _G.dd = function(...)
      Snacks.debug.inspect(...)
    end
    _G.bt = function()
      Snacks.debug.backtrace()
    end
    vim.print = _G.dd
  end,
})

features.add({
  "Add Snacks.nvim toggles",
  setup = function()
    Snacks.toggle.option("spell"):map("<leader>ts")
    Snacks.toggle.indent():map("<leader>ti")
    Snacks.toggle.line_number():map("<leader>tn")
  end,
})

features.add({
  "Do not fold when open a file",
  setup = function()
    -- this soulution will require to use `zR` once before using `zm/zr`.
    vim.o.foldlevel = 99
  end,
})

features.add({
  "Rename a file with Snacks",
  setup = function()
    require("which-key").add({
      {
        "<leader>br",
        function()
          Snacks.rename.rename_file()
        end,
        desc = "Rename File",
      },
    })
  end,
})

features.add({
  "Git interface like EMACS's Magit",
  plugins = {
    {
      "NeogitOrg/neogit",
      dependencies = {
        "nvim-lua/plenary.nvim", -- required
        "sindrets/diffview.nvim", -- optional - Diff integration
      },
      opts = {},
      keys = {
        {
          "<leader>gg",
          function()
            require("neogit").open()
          end,
          desc = "NeoGit",
        },
      },
    },
  },
})

features.add({
  "Autopairs",
  plugins = {
    {
      "windwp/nvim-autopairs",
      event = "InsertEnter",
      opts = {},
    },
  },
})

features.add({
  "Buffer Navigation & Deletion",
  setup = function()
    require("which-key").add({
      {
        "<leader>bn",
        "<cmd>bnext<cr>",
        desc = "Next Buffer",
      },
      {
        "<leader>bp",
        "<cmd>bprevious<cr>",
        desc = "Previous Buffer",
      },
      {
        "<leader>bk",
        function()
          Snacks.bufdelete.delete()
        end,
        desc = "Close Buffer",
      },
      {
        "<leader>bK",
        function()
          Snacks.bufdelete.all()
        end,
        desc = "Close All Buffers",
      },
      {
        "<leader>bb",
        function()
          Snacks.picker.buffers()
        end,
        desc = "Find Buffer",
      },
    })
  end,
})

require("statusline")
require("buffer_filename")

features.add({
  "Tabs control",
  plugins = {
    {
      "nanozuki/tabby.nvim",
      dependencies = {
        "nvim-tree/nvim-web-devicons",
      },
      opts = {
        preset = "tab_only",
        option = {
          nerdfont = true,
        },
      },
    },
  },
  setup = function()
    require("which-key").add({
      {
        "<leader>Tn",
        "<cmd>tabnext<cr>",
        desc = "Next Tab",
      },
      {
        "<leader>Tp",
        "<cmd>tabprevious<cr>",
        desc = "Previous Tab",
      },
      {
        "<leader>Tl",
        "<cmd>+tabmove<cr>",
        desc = "Move Tab Right",
      },
      {
        "<leader>Th",
        "<cmd>-tabmove<cr>",
        desc = "Move Tab Left",
      },
      {
        "<leader>Tt",
        "<cmd>$tabnew<cr>",
        desc = "New Tab",
      },
      {
        "<leader>Tk",
        "<cmd>tabclose<cr>",
        desc = "Close Tab",
      },
      {
        "<leader>Tr",
        function()
          local newname = vim.fn.input("Rename tab to: ")
          require("tabby").tab_rename(newname)
        end,
        desc = "Rename Tab",
      },
      {
        "<leader>To",
        "<cmd>tabonly<cr>",
        desc = "Close Other Tabs",
      },
    })
  end,
})

features.add({
  "Toggle terminal",
  setup = function()
    require("which-key").add({
      {
        "<leader>at",
        function()
          Snacks.terminal.toggle()
        end,
        desc = "Terminal",
      },
    })
  end,
})

features.add({
  "LSP navigation",
  plugins = {
    { "folke/snacks.nvim" },
  },
  setup = function()
    Snacks.toggle.words():map("<leader>tw")

    require("which-key").add({
      {
        "<a-n>",
        function()
          Snacks.words.jump(vim.v.count1, true)
        end,
        desc = "Next Reference",
        cond = function()
          return Snacks.words.is_enabled()
        end,
      },
      {
        "<a-p>",
        function()
          Snacks.words.jump(-vim.v.count1, true)
        end,
        desc = "Previous Reference",
        cond = function()
          return Snacks.words.is_enabled()
        end,
      },
      {
        "gd",
        function()
          Snacks.picker.lsp_definitions()
        end,
        desc = "LSP Definitions",
      },
      {
        "gD",
        function()
          Snacks.picker.lsp_declarations()
        end,
        desc = "LSP Declarations",
      },
      {
        "gI",
        function()
          Snacks.picker.lsp_implementations()
        end,
        desc = "LSP Implementations",
      },
      {
        "gr",
        function()
          Snacks.picker.lsp_references()
        end,
        nowait = true,
        desc = "LSP References",
      },
      {
        "gy",
        function()
          Snacks.picker.lsp_type_definitions()
        end,
        desc = "LSP Type Definitions",
      },
      {
        "<leader>fs",
        function()
          Snacks.picker.lsp_symbols()
        end,
        desc = "LSP Symbols",
      },
    })
  end,
})

features.add({
  "Show git status in the sign column",
  plugins = {
    {
      "lewis6991/gitsigns.nvim",
      opts = {
        signs_staged_enable = false,
      },
    },
  },
  setup = function()
    Snacks.toggle
      .new({
        name = "Git Signs",
        get = function()
          return require("gitsigns.config").config.signcolumn
        end,
        set = function(state)
          require("gitsigns").toggle_signs(state)
        end,
      })
      :map("<leader>tg")
  end,
})

features.add({
  "Git hunks/diffs in-buffer navigation and control",
  plugins = {
    { "lewis6991/gitsigns.nvim" },
  },
  setup = function()
    require("which-key").add({
      {
        "<leader>gn",
        function()
          require("gitsigns").nav_hunk("next")
        end,
        desc = "Next Hunk",
      },
      {
        "<leader>gp",
        function()
          require("gitsigns").nav_hunk("prev")
        end,
        desc = "Previous Hunk",
      },
      {
        "<leader>gv",
        function()
          require("gitsigns").preview_hunk()
        end,
        desc = "Preview Hunk",
      },
      {
        "<leader>gd",
        function()
          require("gitsigns").diffthis()
        end,
        desc = "Diff Current File",
      },
      {
        "<leader>gs",
        function()
          require("gitsigns").stage_hunk()
        end,
        mode = "n",
        desc = "Stage Hunk",
      },
      {
        "<leader>gs",
        function()
          require("gitsigns").stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end,
        mode = "v",
        desc = "Stage Lines",
      },
      {
        "<leader>gr",
        function()
          require("gitsigns").reset_hunk()
        end,
        mode = "n",
        desc = "Reset Hunk",
      },
      {
        "<leader>gr",
        function()
          require("gitsigns").reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end,
        mode = "v",
        desc = "Reset Lines",
      },
      {
        "<leader>gu",
        function()
          require("gitsigns").undo_stage_hunk()
        end,
        desc = "Undo Stage Hunk",
      },
    })
  end,
})

features.add({
  "BLAME!",
  plugins = {
    { "lewis6991/gitsigns.nvim" },
  },
  setup = function()
    Snacks.toggle
      .new({
        name = "Current Line Blame",
        get = function()
          return require("gitsigns.config").config.current_line_blame
        end,
        set = function(state)
          require("gitsigns").toggle_current_line_blame(state)
        end,
      })
      :map("<leader>tb")

    require("which-key").add({
      {
        "<leader>gb",
        function()
          require("gitsigns").blame_line()
        end,
        desc = "Blame Line",
      },
      {
        "<leader>gB",
        function()
          require("gitsigns").blame()
        end,
        desc = "Blame",
      },
    })
  end,
})

features.add({
  "Better w/e/b navigation",
  plugins = {
    {
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
  },
})

features.add({
  "More intiutive integration with system clipboard",
  setup = function()
    vim.opt.clipboard:append("unnamedplus")
  end,
})

features.add({
  "Adjust spell checking",
  setup = function()
    vim.o.spelllang = "en_us"
  end,
})

features.add({
  "More granular undo for text in insert mode",
  setup = function()
    -- https://stackoverflow.com/questions/2895551/how-do-i-get-fine-grained-undo-in-vim
    vim.cmd.inoremap("<Space>", "<Space><C-g>u")
  end,
})

features.add({
  "Chat with LLM",
  plugins = {
    {
      "robitx/gp.nvim",
      opts = {
        openai_api_key = { "pass", "openai/api_key" },
        providers = {
          anthropic = {
            secret = { "pass", "anthropic/api_key" },
          },
        },
      },
    },
  },
  setup = function()
    require("which-key").add({
      -- VISUAL mode mappings
      -- s, x, v modes are handled the same way by which_key
      {
        mode = { "v" },
        nowait = true,
        remap = false,
        { "<C-g><C-t>", ":<C-u>'<,'>GpChatNew tabnew<cr>", desc = "ChatNew tabnew" },
        { "<C-g><C-v>", ":<C-u>'<,'>GpChatNew vsplit<cr>", desc = "ChatNew vsplit" },
        { "<C-g><C-x>", ":<C-u>'<,'>GpChatNew split<cr>", desc = "ChatNew split" },
        { "<C-g>a", ":<C-u>'<,'>GpAppend<cr>", desc = "Visual Append (after)" },
        { "<C-g>b", ":<C-u>'<,'>GpPrepend<cr>", desc = "Visual Prepend (before)" },
        { "<C-g>c", ":<C-u>'<,'>GpChatNew<cr>", desc = "Visual Chat New" },
        { "<C-g>g", group = "generate into new .." },
        { "<C-g>ge", ":<C-u>'<,'>GpEnew<cr>", desc = "Visual GpEnew" },
        { "<C-g>gn", ":<C-u>'<,'>GpNew<cr>", desc = "Visual GpNew" },
        { "<C-g>gp", ":<C-u>'<,'>GpPopup<cr>", desc = "Visual Popup" },
        { "<C-g>gt", ":<C-u>'<,'>GpTabnew<cr>", desc = "Visual GpTabnew" },
        { "<C-g>gv", ":<C-u>'<,'>GpVnew<cr>", desc = "Visual GpVnew" },
        { "<C-g>i", ":<C-u>'<,'>GpImplement<cr>", desc = "Implement selection" },
        { "<C-g>n", "<cmd>GpNextAgent<cr>", desc = "Next Agent" },
        { "<C-g>p", ":<C-u>'<,'>GpChatPaste<cr>", desc = "Visual Chat Paste" },
        { "<C-g>r", ":<C-u>'<,'>GpRewrite<cr>", desc = "Visual Rewrite" },
        { "<C-g>s", "<cmd>GpStop<cr>", desc = "GpStop" },
        { "<C-g>t", ":<C-u>'<,'>GpChatToggle<cr>", desc = "Visual Toggle Chat" },
        { "<C-g>w", group = "Whisper" },
        { "<C-g>wa", ":<C-u>'<,'>GpWhisperAppend<cr>", desc = "Whisper Append" },
        { "<C-g>wb", ":<C-u>'<,'>GpWhisperPrepend<cr>", desc = "Whisper Prepend" },
        { "<C-g>we", ":<C-u>'<,'>GpWhisperEnew<cr>", desc = "Whisper Enew" },
        { "<C-g>wn", ":<C-u>'<,'>GpWhisperNew<cr>", desc = "Whisper New" },
        { "<C-g>wp", ":<C-u>'<,'>GpWhisperPopup<cr>", desc = "Whisper Popup" },
        { "<C-g>wr", ":<C-u>'<,'>GpWhisperRewrite<cr>", desc = "Whisper Rewrite" },
        { "<C-g>wt", ":<C-u>'<,'>GpWhisperTabnew<cr>", desc = "Whisper Tabnew" },
        { "<C-g>wv", ":<C-u>'<,'>GpWhisperVnew<cr>", desc = "Whisper Vnew" },
        { "<C-g>ww", ":<C-u>'<,'>GpWhisper<cr>", desc = "Whisper" },
        { "<C-g>x", ":<C-u>'<,'>GpContext<cr>", desc = "Visual GpContext" },
      },

      -- NORMAL mode mappings
      {
        mode = { "n" },
        nowait = true,
        remap = false,
        { "<C-g><C-t>", "<cmd>GpChatNew tabnew<cr>", desc = "New Chat tabnew" },
        { "<C-g><C-v>", "<cmd>GpChatNew vsplit<cr>", desc = "New Chat vsplit" },
        { "<C-g><C-x>", "<cmd>GpChatNew split<cr>", desc = "New Chat split" },
        { "<C-g>a", "<cmd>GpAppend<cr>", desc = "Append (after)" },
        { "<C-g>b", "<cmd>GpPrepend<cr>", desc = "Prepend (before)" },
        { "<C-g>c", "<cmd>GpChatNew<cr>", desc = "New Chat" },
        { "<C-g>f", "<cmd>GpChatFinder<cr>", desc = "Chat Finder" },
        { "<C-g>g", group = "generate into new .." },
        { "<C-g>ge", "<cmd>GpEnew<cr>", desc = "GpEnew" },
        { "<C-g>gn", "<cmd>GpNew<cr>", desc = "GpNew" },
        { "<C-g>gp", "<cmd>GpPopup<cr>", desc = "Popup" },
        { "<C-g>gt", "<cmd>GpTabnew<cr>", desc = "GpTabnew" },
        { "<C-g>gv", "<cmd>GpVnew<cr>", desc = "GpVnew" },
        { "<C-g>n", "<cmd>GpNextAgent<cr>", desc = "Next Agent" },
        { "<C-g>r", "<cmd>GpRewrite<cr>", desc = "Inline Rewrite" },
        { "<C-g>s", "<cmd>GpStop<cr>", desc = "GpStop" },
        { "<C-g>t", "<cmd>GpChatToggle<cr>", desc = "Toggle Chat" },
        { "<C-g>w", group = "Whisper" },
        { "<C-g>wa", "<cmd>GpWhisperAppend<cr>", desc = "Whisper Append (after)" },
        { "<C-g>wb", "<cmd>GpWhisperPrepend<cr>", desc = "Whisper Prepend (before)" },
        { "<C-g>we", "<cmd>GpWhisperEnew<cr>", desc = "Whisper Enew" },
        { "<C-g>wn", "<cmd>GpWhisperNew<cr>", desc = "Whisper New" },
        { "<C-g>wp", "<cmd>GpWhisperPopup<cr>", desc = "Whisper Popup" },
        { "<C-g>wr", "<cmd>GpWhisperRewrite<cr>", desc = "Whisper Inline Rewrite" },
        { "<C-g>wt", "<cmd>GpWhisperTabnew<cr>", desc = "Whisper Tabnew" },
        { "<C-g>wv", "<cmd>GpWhisperVnew<cr>", desc = "Whisper Vnew" },
        { "<C-g>ww", "<cmd>GpWhisper<cr>", desc = "Whisper" },
        { "<C-g>x", "<cmd>GpContext<cr>", desc = "Toggle GpContext" },
      },

      -- INSERT mode mappings
      {
        mode = { "i" },
        nowait = true,
        remap = false,
        { "<C-g><C-t>", "<cmd>GpChatNew tabnew<cr>", desc = "New Chat tabnew" },
        { "<C-g><C-v>", "<cmd>GpChatNew vsplit<cr>", desc = "New Chat vsplit" },
        { "<C-g><C-x>", "<cmd>GpChatNew split<cr>", desc = "New Chat split" },
        { "<C-g>a", "<cmd>GpAppend<cr>", desc = "Append (after)" },
        { "<C-g>b", "<cmd>GpPrepend<cr>", desc = "Prepend (before)" },
        { "<C-g>c", "<cmd>GpChatNew<cr>", desc = "New Chat" },
        { "<C-g>f", "<cmd>GpChatFinder<cr>", desc = "Chat Finder" },
        { "<C-g>g", group = "generate into new .." },
        { "<C-g>ge", "<cmd>GpEnew<cr>", desc = "GpEnew" },
        { "<C-g>gn", "<cmd>GpNew<cr>", desc = "GpNew" },
        { "<C-g>gp", "<cmd>GpPopup<cr>", desc = "Popup" },
        { "<C-g>gt", "<cmd>GpTabnew<cr>", desc = "GpTabnew" },
        { "<C-g>gv", "<cmd>GpVnew<cr>", desc = "GpVnew" },
        { "<C-g>n", "<cmd>GpNextAgent<cr>", desc = "Next Agent" },
        { "<C-g>r", "<cmd>GpRewrite<cr>", desc = "Inline Rewrite" },
        { "<C-g>s", "<cmd>GpStop<cr>", desc = "GpStop" },
        { "<C-g>t", "<cmd>GpChatToggle<cr>", desc = "Toggle Chat" },
        { "<C-g>w", group = "Whisper" },
        { "<C-g>wa", "<cmd>GpWhisperAppend<cr>", desc = "Whisper Append (after)" },
        { "<C-g>wb", "<cmd>GpWhisperPrepend<cr>", desc = "Whisper Prepend (before)" },
        { "<C-g>we", "<cmd>GpWhisperEnew<cr>", desc = "Whisper Enew" },
        { "<C-g>wn", "<cmd>GpWhisperNew<cr>", desc = "Whisper New" },
        { "<C-g>wp", "<cmd>GpWhisperPopup<cr>", desc = "Whisper Popup" },
        { "<C-g>wr", "<cmd>GpWhisperRewrite<cr>", desc = "Whisper Inline Rewrite" },
        { "<C-g>wt", "<cmd>GpWhisperTabnew<cr>", desc = "Whisper Tabnew" },
        { "<C-g>wv", "<cmd>GpWhisperVnew<cr>", desc = "Whisper Vnew" },
        { "<C-g>ww", "<cmd>GpWhisper<cr>", desc = "Whisper" },
        { "<C-g>x", "<cmd>GpContext<cr>", desc = "Toggle GpContext" },
      },
    })
  end,
})

features.add({
  "Convinient search/replace UI (grug-far)",
  plugins = {
    {
      "MagicDuck/grug-far.nvim",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      opts = {},
    },
  },
  setup = function()
    local gf = require("grug-far")

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
      { "<leader>ss", "<cmd>GrugFar ripgrep<cr>", desc = "Search in project (ripgrep)" },
      { "<leader>sS", "<cmd>GrugFar astgrep<cr>", desc = "Search in project (ast-grep)" },
      { "<leader>sw", search_word_ripgrep, desc = "Search word in project (ripgrep)" },
      { "<leader>sf", search_file_ripgrep, desc = "Search in file (ripgrep)" },
      { "<leader>sF", search_file_astgrep, desc = "Search in file (ast-grep)" },
    })
  end,
})

features.add({
  "Fancy diff view (uncommitted changes & file/branch history)",
  plugins = {
    {
      "sindrets/diffview.nvim",
      dependencies = {
        "nvim-tree/nvim-web-devicons",
      },
      init = function()
        -- fancy diff for deleted lines
        vim.opt.fillchars:append({ diff = "╱" })
      end,
      opts = {
        enhanced_diff_hl = true,
      },
    },
  },
  setup = function()
    require("which-key").add({
      {
        "<leader>gD",
        "<cmd>DiffviewOpen<cr>",
        desc = "Diff Unstaged",
      },
      {
        "<leader>gh",
        "<cmd>DiffviewFileHistory %<cr>",
        desc = "File History",
      },
      {
        "<leader>gH",
        "<cmd>DiffviewFileHistory<cr>",
        desc = "Branch History",
      },
    })
  end,
})

features.add({
  "Toggle word/line wrapping",
  setup = function()
    Snacks.toggle.option("wrap", { global = false }):map("<leader>tl")
    Snacks.toggle.option("linebreak", { global = false }):map("<leader>tw")
  end,
})

features.add({
  "Explore diagnostics/location/quickfix/lsp lists (trouble.nvim)",
  plugins = {
    {
      "folke/trouble.nvim",
      opts = {},
      cmd = "Trouble",
    },
  },
  setup = function()
    require("which-key").add({
      {
        "<leader>xx",
        "<cmd>Trouble diagnostics toggle filter.buf=0 focus=true<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      {
        "<leader>xX",
        "<cmd>Trouble diagnostics toggle focus=true<cr>",
        desc = "Diagnostics (Trouble)",
      },
      {
        "<leader>xl",
        "<cmd>Trouble loclist toggle focus=true<cr>",
        desc = "Location List (Trouble)",
      },
      {
        "<leader>xs",
        function()
          ---@diagnostic disable-next-line: missing-fields
          require("trouble").toggle({
            mode = "symbols",
            focus = true,
            win = {
              size = {
                width = 120,
              },
            },
          })
        end,
        desc = "Symbols (Trouble)",
      },
      {
        "<leader>xl",
        function()
          ---@diagnostic disable-next-line: missing-fields
          require("trouble").toggle({
            mode = "lsp",
            focus = true,
            win = {
              position = "right",
              size = {
                width = 120,
              },
            },
          })
        end,
        desc = "LSP Definitions / references / ... (Trouble)",
      },
      {
        "<leader>xq",
        "<cmd>Trouble qflist toggle<cr>",
        desc = "Quickfix List (Trouble)",
      },
    })
  end,
})

features.add({
  "Control LSP status",
  setup = function()
    require("which-key").add({
      { "<leader>ul", group = "LSP" },
      { "<leader>ull", "<cmd>LspInfo<cr>", desc = "LSP info" },
      { "<leader>ulL", "<cmd>LspLog<cr>", desc = "LSP log" },
      { "<leader>uls", "<cmd>LspStart<cr>", desc = "LSP start" },
      { "<leader>ulx", "<cmd>LspStop<cr>", desc = "LSP stop" },
      { "<leader>ulr", "<cmd>LspRestart<cr>", desc = "LSP restart" },
    })
  end,
})

features.add({
  "Undo-Tree",
  plugins = {
    {
      "jiaoshijie/undotree",
      dependencies = { "nvim-lua/plenary.nvim" },
      opts = {},
      keys = {
        {
          "<leader>uu",
          function()
            require("undotree").toggle()
          end,
          desc = "Undo Tree",
        },
      },
    },
  },
})

features.add({
  "Copy current relative file path with line number",
  setup = function()
    local copy_relative_path_with_linum = function()
      local path = vim.fn.expand("%:.")
      local line = vim.fn.line(".")
      local text = string.format("%s:%d", path, line)
      vim.fn.setreg("+", text)
      vim.notify("Copied: " .. text)
    end

    require("which-key").add({
      {
        "<leader>ey",
        copy_relative_path_with_linum,
        desc = "Copy Relative Path with Line Number",
      },
    })
  end,
})

features.add({
  "Copilot Chat",
  plugins = {
    {
      "CopilotC-Nvim/CopilotChat.nvim",
      dependencies = {
        { "zbirenbaum/copilot.lua" },
        { "nvim-lua/plenary.nvim" },
      },
      build = "make tiktoken",
      ---@module "CopilotChat"
      ---@type CopilotChat.config
      opts = {
        model = "claude-3.5-sonnet",
        auto_insert_mode = true,
      },
    },
  },
  setup = function()
    --- Adjust completion behavior
    vim.api.nvim_create_autocmd("BufEnter", {
      pattern = "copilot-*",
      callback = function()
        vim.opt_local.completeopt = "menu,preview,noinsert,popup"
      end,
    })

    require("which-key").add({
      { "<leader>ac", group = "Copilot Chat" },
      { "<leader>acc", "<cmd>CopilotChatToggle<cr>", desc = "Toggle Chat" },
      { "<leader>acm", "<cmd>CopilotChatModel<cr>", desc = "Change Model" },
      { "<leader>acs", "<cmd>CopilotChatCommitStaged<cr>", desc = "Commit Message (staged)" },
      {
        "<leader>acq",
        function()
          vim.ui.input({ prompt = "Quick Chat: " }, function(input)
            if input ~= "" then
              require("CopilotChat").ask(input, { selection = require("CopilotChat.select").buffer })
            end
          end)
        end,
        desc = "Quick chat",
      },
    })
  end,
})

features.add({
  "Support for Kitty terminal config",
  plugins = {
    {
      "fladson/vim-kitty",
      ft = "kitty",
    },
  },
})

-- TODO: togglable LSP symbols path in incline, statusline or popup like with " gb"

features.load()
