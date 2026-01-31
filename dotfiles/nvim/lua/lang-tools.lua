-- Objective: integrate LSP, formatters, linters and other language tools in Neovim

---@module "snacks"

local features = require("features")

features.add({
  "Enable & configure LSP servers",
  after = { "blink" },
  plugins = {
    {
      "neovim/nvim-lspconfig",
      config = function()
        require("lspconfig")

        vim.lsp.config('lexical', {
          cmd = { "lexical" },
        })

        vim.lsp.config('elixirls', {
          cmd = { "elixir-ls" },
        })

        vim.lsp.config('expert', {
          cmd = { "expert", "--stdio" },
        })

        vim.lsp.config('cssls', {
          settings = {
            css = {
              lint = {
                unknownAtRules = "ignore",
              },
            },
          },
        })

        vim.lsp.enable({
          'cssls',
          'dockerls',
          'eslint',
          'jsonls',
          'gopls',
          'html',
          'hyprls',
          'lexical',
          'elixirls',
          'expert',
          'lua_ls',
          'nixd',
          'rust_analyzer',
          'svelte',
          'tailwindcss',
          'terraformls',
          'ts_ls',
          'zls',
        })
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
  "Formatting",
  after = { "which-key" },
  plugins = {
    {
      "stevearc/conform.nvim",
      ---@type conform.setupOpts
      opts = {
        format_on_save = {
          timeout_ms = 500,
        },
        default_format_opts = {
          lsp_format = "fallback",
        },
        formatters_by_ft = {
          elixir = { "mix" },
          terraform = { "terraform_fmt" },
          zig = { "zigfmt" },
          json = { "prettier" },
        },
      },
    },
  },
  setup = function()
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

    local conform = require("conform")
    require("which-key").add({
      {
        "<leader>lf",
        function()
          conform.format({ async = false })
        end,
        desc = "Format Buffer"
      },
      {
        "<leader>lF",
        function()
          conform.format({ async = true })
        end,
        desc = "Format Buffer (async)"
      },
      {
        "<leader>uf", "<cmd>ConformInfo<cr>", desc = "Formatters Info"
      }
    })
  end,
})

features.add({
  "Linting",
  after = { "which-key", "lualine" },
  plugins = {
    { "mfussenegger/nvim-lint" },
    {
      "nvim-lualine/lualine.nvim",
      opts = function(_, opts)
        table.insert(opts.sections.lualine_x, 2, {
          function()
            local linters = require("lint").get_running()
            if #linters == 0 then
              return ""
            end
            return " " .. table.concat(linters, ", ")
          end,
          color = function()
            return { fg = require("utils").getFgHexColorFromHighlight("DiagnosticWarn") }
          end
        })
      end
    }
  },
  setup = function()
    local lint = require("lint")

    lint.linters_by_ft = {
      dockerfile = { "hadolint" },
      elixir = { "credo" },
      nix = { "statix" },
      terraform = { "terraform_validate" },
      zig = { "zig", "zlint" },
      zsh = { "zsh" },
    }

    vim.api.nvim_create_autocmd({ "BufWritePost" }, {
      callback = function()
        lint.try_lint()
      end,
    })
  end
})

features.add({
  "LSP UI/UX",
  after = { "which-key", "snacks" },
  plugins = {
    {
      "nvimdev/lspsaga.nvim",
      dependencies = { "nvim-tree/nvim-web-devicons", "nvim-treesitter/nvim-treesitter" },
      config = function()
        require("lspsaga").setup({
          symbol_in_winbar = {
            enabled = true,
            show_file = false,
          },
          lightbulb = {
            enable = true,
            sign = false,
            virtual_text = true,
            debounce = 3000,
          },
          outline = {
            win_width = 60,
          }
        })
      end,
    },
    {
      "aznhe21/actions-preview.nvim",
      opts = {
        backend = { "snacks" },
      },
    }
  },
  setup = function()
    local list_workspace_folders = function()
      local unique_folders = {}
      for _, folder in ipairs(vim.lsp.buf.list_workspace_folders()) do
        unique_folders[folder] = true
      end

      if vim.tbl_count(unique_folders) == 0 then
        vim.notify("No workspace folders found", vim.log.levels.WARN)
        return
      end

      local msg = "Workspace Folders:\n\n"
      for folder in pairs(unique_folders) do
        msg = msg .. string.format("%s\n", folder)
      end
      vim.notify(msg, vim.log.levels.INFO)
    end

    Snacks.toggle.inlay_hints():map("<leader>TI")

    local lsp_log = function()
      vim.cmd('tabnew ' .. vim.lsp.log.get_filename())
    end

    require("which-key").add({
      -- LSP pickers, Snacks.picker powered when possible
      -- I avoid lspsaga pickers to have a more consistent experience
      { "<leader>ld",  Snacks.picker.lsp_definitions,           desc = "Definitions" },
      { "<leader>lD",  Snacks.picker.lsp_declarations,          desc = "Declarations" },
      { "<leader>li",  Snacks.picker.lsp_implementations,       desc = "Implementations", },
      { "<leader>lr",  Snacks.picker.lsp_references,            desc = "References", },
      { "<leader>lt",  Snacks.picker.lsp_type_definitions,      desc = "Type Definitions" },
      { "<leader>ls",  Snacks.picker.lsp_symbols,               desc = "Local Symbols" },
      { "<leader>lS",  Snacks.picker.lsp_workspace_symbols,     desc = "Workspace Symbols" },
      { "<leader>lc",  Snacks.picker.lsp_incoming_calls,        desc = "Incoming Calls" },
      { "<leader>lC",  Snacks.picker.lsp_outgoing_calls,        desc = "Outgoing Calls" },
      { "<leader>lT",  vim.lsp.buf.typehierarchy,               desc = "Type Hierarchy" },

      -- LSP saga peek commands
      { "<leader>lp",  group = "LSP Peek" },
      { "<leader>lpd", "<cmd>Lspsaga peek_definition<cr>",      desc = "Peek Definition" },
      { "<leader>lpt", "<cmd>Lspsaga peek_type_definition<cr>", desc = "Peek Type Definition" },

      -- LSP saga hover doc
      { "K",           "<cmd>Lspsaga hover_doc<cr>",            desc = "Hover Documentation" },

      -- LSP saga outline
      { "<leader>lo",  "<cmd>Lspsaga outline<cr>",              desc = "LSP Outline" },

      -- LSP diagnostic jumping
      { "]e",          "<cmd>Lspsaga diagnostic_jump_next<cr>", desc = "Next Diagnostic" },
      { "[e",          "<cmd>Lspsaga diagnostic_jump_prev<cr>", desc = "Previous Diagnostic" },
      { "<leader>le",  group = "Diagnostics" },
      { "<leader>lee", "<cmd>Lspsaga show_buf_diagnostics<cr>", desc = "Show buffer diagnostics" },
      { "<leader>lep", "<cmd>Lspsaga diagnostic_jump_prev<cr>", desc = "Previous Diagnostic" },
      { "<leader>len", "<cmd>Lspsaga diagnostic_jump_next<cr>", desc = "Next Diagnostic" },

      -- LSP commands
      { "<leader>ln",  "<cmd>Lspsaga rename ++project<cr>",     desc = "Rename Symbol" },

      -- Code lenses
      { "<leader>ll",  vim.lsp.codelens.refresh,                desc = "Refresh Code Lenses" },
      { "<leader>lL",  vim.lsp.codelens.run,                    desc = "Run Code Lens" },

      -- Workspace commands
      { "<leader>lw",  group = "Workspace Folders" },
      { "<leader>lwa", vim.lsp.buf.add_workspace_folder,        desc = "Add Workspace Folder" },
      { "<leader>lwr", vim.lsp.buf.remove_workspace_folder,     desc = "Remove Workspace Folder" },
      { "<leader>lwl", list_workspace_folders,                  desc = "List Workspace Folders" },

      -- Apply LSP actions with preview
      { "<leader>la",  require("actions-preview").code_actions, desc = "Code Actions" },

      -- LSP Server Control
      { "<leader>lx",  group = "LSP Server" },
      { "<leader>lxc", Snacks.picker.lsp_config,                desc = "Configs" },
      { "<leader>lxl", lsp_log,                                 desc = "Logs" },
      { "<leader>lxr", "<cmd>lsp restart<cr>",                  desc = "Restart" },
      { "<leader>lxs", "<cmd>lsp start<cr>",                    desc = "Start" },
      { "<leader>lxx", "<cmd>lsp stop<cr>",                     desc = "Stop" },
    })
  end
})

features.add({
  "LSP navigation between references",
  after = { "which-key", "snacks" },
  setup = function()
    Snacks.toggle.words():map("<leader>TW")

    local jump_next = function()
      Snacks.words.jump(vim.v.count1, true)
    end

    local jump_prev = function()
      Snacks.words.jump(-vim.v.count1, true)
    end

    require("which-key").add({
      { "<M-n>", jump_next, desc = "Next Reference" },
      { "<M-p>", jump_prev, desc = "Previous Reference" },
    })
  end,
})

features.add({
  "Switch LSP-backed folding when possible",
  setup = function()
    vim.api.nvim_create_autocmd('LspAttach', {
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        local win = vim.api.nvim_get_current_win()

        if client and client:supports_method('textDocument/foldingRange') then
          vim.wo[win][0].foldexpr = 'v:lua.vim.lsp.foldexpr()'
        end
      end,
    })
  end
})

features.add({
  "LSP inline-completion toggle",
  after = { "which-key" },
  setup = function()
    vim.lsp.inline_completion.enable()

    Snacks.toggle.new({
      name = "LSP Inline Completion",
      get = function()
        return vim.lsp.inline_completion.is_enabled()
      end,
      set = function(state)
        vim.lsp.inline_completion.enable(state)
      end
    }):map("<leader>Tc")
  end
})

features.add({
  "Advanced test runner",
  after = { "which-key" },
  plugins = {
    {
      "nvim-neotest/neotest",
      dependencies = {
        "nvim-neotest/nvim-nio",
        "nvim-lua/plenary.nvim",
        "antoinemadec/FixCursorHold.nvim",
        "nvim-treesitter/nvim-treesitter",
        -- adapters
        "jfpedroza/neotest-elixir"
      },
      config = function()
        ---@diagnostic disable-next-line: missing-fields
        require("neotest").setup({
          adapters = {
            require("neotest-elixir"),
          }
        })
      end
    }
  },
  setup = function()
    require("which-key").add({
      { "<leader>uT",  group = "NeoTest" },
      -- Running tests
      { "<leader>uTt", "<cmd>Neotest run<cr>",          desc = "Run Nearest Test" },
      { "<leader>uTf", "<cmd>Neotest run file<cr>",     desc = "Run File Tests" },
      { "<leader>uTl", "<cmd>Neotest run last<cr>",     desc = "Run Last Test" },
      { "<leader>uTx", "<cmd>Neotest stop<cr>",         desc = "Stop Test" },

      -- Summary and output
      { "<leader>uTs", "<cmd>Neotest summary<cr>",      desc = "Test Summary" },
      { "<leader>uTo", "<cmd>Neotest output<cr>",       desc = "Show Test Output" },
      { "<leader>uTO", "<cmd>Neotest output_panel<cr>", desc = "Show Test Output Panel" },
    })
  end
})

features.add({
  "Simple test runner",
  after = { "which-key" },
  plugins = {
    {
      "quolpr/quicktest.nvim",
      config = function()
        local qt = require("quicktest")

        qt.setup({
          adapters = {
            require("quicktest.adapters.golang")({}),
            require("quicktest.adapters.vitest")({}),
            require("quicktest.adapters.playwright")({}),
            require("quicktest.adapters.pytest")({}),
            require("quicktest.adapters.elixir"),
          },
          -- split or popup mode, when argument not specified
          default_win_mode = "split",
          use_builtin_colorizer = true
        })
      end,
      dependencies = {
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
      },
    }
  },
  setup = function()
    local qt = require("quicktest")

    require("which-key").add({
      { "<leader>ut", group = "Quicktest" },
      {
        "<leader>utt",
        qt.run_line,
        desc = "Test Current Line",
      },
      {
        "<leader>utf",
        qt.run_file,
        desc = "Test Current File",
      },
      {
        '<leader>utd',
        qt.run_dir,
        desc = 'Test Current Directory',
      },
      {
        '<leader>uta',
        qt.run_all
        ,
        desc = 'Run All',
      },
      {
        "<leader>tp",
        qt.run_previous,
        desc = "Run Previous",
      },
      {
        "<leader>utw",
        function()
          qt.toggle_win("split")
        end,
        desc = "Toggle Test Window",
      },
      {
        "<leader>utx",
        qt.cancel_current_run,
        desc = "Stop Current Run",
      }
    })
  end,
})
