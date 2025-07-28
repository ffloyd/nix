-- Objective: integrate LSP, formatters, linters and other language tools in Neovim

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

        vim.lsp.enable({
          'cssls',
          'dockerls',
          'eslint',
          'jsonls',
          'gopls',
          'html',
          'lexical',
          'lua_ls',
          'nixd',
          'rust_analyzer',
          'svelte',
          'tailwindcss',
          'terraformls',
          'ts_ls',
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
  "Enable formatters & linters via null-ls",
  after = { "which-key" },
  plugins = {
    {
      "nvimtools/none-ls.nvim",
      opts = function(_, opts)
        local null_ls = require("null-ls")

        opts.sources = {
          -- Formatters
          null_ls.builtins.formatting.nix_flake_fmt,
          null_ls.builtins.formatting.mix,
          null_ls.builtins.formatting.terraform_fmt,
          -- Linters
          null_ls.builtins.diagnostics.credo,
          null_ls.builtins.diagnostics.editorconfig_checker,
          null_ls.builtins.diagnostics.hadolint,
          null_ls.builtins.diagnostics.statix,
          null_ls.builtins.diagnostics.terraform_validate,
          null_ls.builtins.diagnostics.trail_space,
          null_ls.builtins.diagnostics.zsh,
          -- Hovers
          null_ls.builtins.hover.dictionary,
          null_ls.builtins.hover.printenv,
        }
      end,
    },
  },
})

features.add({
  "Expose core LSP commands using fancy wrappers when possible",
  after = { "which-key", "snacks" },
  plugins = {
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

    require("which-key").add({
      -- Snacks-powered LSP pickers
      { "<leader>ld",  Snacks.picker.lsp_definitions,           desc = "Definitions" },
      { "<leader>lD",  Snacks.picker.lsp_declarations,          desc = "Declarations" },
      { "<leader>li",  Snacks.picker.lsp_implementations,       desc = "Implementations", },
      { "<leader>lr",  Snacks.picker.lsp_references,            desc = "References", },
      { "<leader>lt",  Snacks.picker.lsp_type_definitions,      desc = "Type Definitions" },
      { "<leader>ls",  Snacks.picker.lsp_symbols,               desc = "Local Symbols" },
      { "<leader>lS",  Snacks.picker.lsp_workspace_symbols,     desc = "Workspace Symbols" },

      -- LSP commands
      { "<leader>ln",  vim.lsp.buf.rename,                      desc = "Rename Symbol" },
      { "<leader>lf",  vim.lsp.buf.format,                      desc = "Format Buffer" },
      { "<leader>ll",  vim.lsp.codelens.refresh,                desc = "Refresh Code Lenses" },
      { "<leader>lL",  vim.lsp.codelens.run,                    desc = "Run Code Lens" },

      -- Call hierarchy commands
      { "<leader>lc",  vim.lsp.buf.incoming_calls,              desc = "Incoming Calls" },
      { "<leader>lC",  vim.lsp.buf.outgoing_calls,              desc = "Outgoing Calls" },
      { "<leader>lT",  vim.lsp.buf.typehierarchy,               desc = "Type Hierarchy" },

      -- Workspace commands
      { "<leader>lw",  group = "Workspace Folders" },
      { "<leader>lwa", vim.lsp.buf.add_workspace_folder,        desc = "Add Workspace Folder" },
      { "<leader>lwr", vim.lsp.buf.remove_workspace_folder,     desc = "Remove Workspace Folder" },
      { "<leader>lwl", list_workspace_folders,                  desc = "List Workspace Folders" },

      -- Apply LSP actions with preview
      { "<leader>la",  require("actions-preview").code_actions, desc = "Code Actions" },

      -- LSP Server Control
      { "<leader>ls",  group = "LSP Server" },
      { "<leader>lsc", Snacks.picker.lsp_config,                desc = "Configs" },
      { "<leader>lsl", "<cmd>LspLog<cr>",                       desc = "Logs" },
      { "<leader>lsr", "<cmd>LspRestart<cr>",                   desc = "Restart" },
      { "<leader>lss", "<cmd>LspStart<cr>",                     desc = "Start" },
      { "<leader>lsx", "<cmd>LspStop<cr>",                      desc = "Stop" },
    })
  end
})

features.add({
  "Indicate presence of LSP actions",
  after = { "which-key", "snacks" },
  plugins = {
    {
      "kosayoda/nvim-lightbulb",
      ---@type nvim-lightbulb.Config
      ---@diagnostic disable-next-line: missing-fields
      opts = {
        code_lenses = true,
        autocmd = {
          enabled = true,
        },
        filter = function(client_name, result)
          if client_name == "lexical" and result.kind == "source.organizeImports" then
            return false
          end

          return true
        end,
      },
    },
  },
  setup = function()
    local lightbulb_enabled = true
    local nvim_lightbulb = require("nvim-lightbulb")

    Snacks.toggle
        .new({
          name = "LSP Actions Lightbulb",
          get = function()
            return lightbulb_enabled
          end,
          set = function(state)
            ---@type nvim-lightbulb.Config
            ---@diagnostic disable-next-line: missing-fields
            local next_config = {
              code_lenses = state,
              autocmd = { enabled = state },
              sign = { enabled = state },
            }

            nvim_lightbulb.update_lightbulb(next_config)
            nvim_lightbulb.setup(next_config)

            lightbulb_enabled = state
          end,
        })
        :map("<leader>lA")
  end,
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
  "Switch LSP-backed folding and formatting when possible",
  setup = function()
    vim.api.nvim_create_autocmd('LspAttach', {
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        local win = vim.api.nvim_get_current_win()
        local bufnr = vim.api.nvim_get_current_buf()

        if client and client:supports_method('textDocument/foldingRange') then
          vim.wo[win][0].foldexpr = 'v:lua.vim.lsp.foldexpr()'
        end

        if client and client:supports_method('textDocument/formatting') then
          vim.bo[bufnr].formatexpr = 'v:lua.vim.lsp.formatexpr()'
        end
      end,
    })
  end
})
