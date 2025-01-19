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
      { "<leader>b", group = "Buffer" },
      { "<leader>g", group = "Git/VCS" },
      { "<leader>f", group = "Finders" },
      { "<leader>t", group = "Toggle" },
      { "<leader>?", group = "Discover" },
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
  "Fetch default configurations for LSP servers",
  plugins = {
    {
      "neovim/nvim-lspconfig",
      config = function()
        local lspconfig = require("lspconfig")

        lspconfig.dockerls.setup({})
        lspconfig.lua_ls.setup({})
        lspconfig.gopls.setup({})
        lspconfig.lexical.setup({
          cmd = { "lexical" },
        })
        lspconfig.nixd.setup({})
        lspconfig.terraformls.setup({})
        lspconfig.ts_ls.setup({})
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
        opts.statuscolumn = { enabled = true }
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
  "Search files by <leader><leader>",
  setup = function()
    require("which-key").add({
      {
        "<leader><leader>",
        function()
          Snacks.picker.files()
        end,
        desc = "files",
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
    Snacks.toggle.line_number():map("<leader>tn")
    Snacks.toggle.indent():map("<leader>ti")
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
    },
  },
  setup = function()
    require("which-key").add({
      {
        "<leader>gg",
        function()
          require("neogit").open()
        end,
        desc = "Neogit",
      },
    })
  end,
})

features.load()
