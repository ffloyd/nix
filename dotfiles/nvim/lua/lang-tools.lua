-- Objective: integrate LSP, formatters, linters and other language tools in Neovim

local features = require("features")

features.add({
  "Fetch default configurations for LSP servers (with respect to blink.cmp)",
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
  "Formatters and Linters via null-ls",
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
  setup = function()
    require("which-key").add({
      {
        "<leader>ef",
        function()
          vim.lsp.buf.format()
        end,
        desc = "Format Buffer",
      },
    })
  end,
})

features.add({
  "Make LSP actions more discoverable",
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
        :map("<leader>ta")
  end,
})

features.add({
  "LSP code actions & rename",
  after = { "which-key", "snacks" },
  plugins = {
    {
      "aznhe21/actions-preview.nvim",
      opts = {
        backend = { "snacks" },
      },
    },
  },
  setup = function()
    require("which-key").add({
      {
        "<leader>ea",
        function()
          require("actions-preview").code_actions()
        end,
        desc = "LSP Code Actions",
      },
      {
        "<leader>er",
        function()
          vim.lsp.buf.rename()
        end,
        desc = "LSP Rename",
      },
    })
  end,
})

features.add({
  "Control LSP status",
  after = { "which-key" },
  setup = function()
    require("which-key").add({
      { "<leader>ul",  group = "LSP" },
      { "<leader>ull", "<cmd>LspInfo<cr>",    desc = "LSP info" },
      { "<leader>ulL", "<cmd>LspLog<cr>",     desc = "LSP log" },
      { "<leader>uls", "<cmd>LspStart<cr>",   desc = "LSP start" },
      { "<leader>ulx", "<cmd>LspStop<cr>",    desc = "LSP stop" },
      { "<leader>ulr", "<cmd>LspRestart<cr>", desc = "LSP restart" },
    })
  end,
})

features.add({
  "LSP navigation",
  plugins = {
    { "folke/snacks.nvim" },
  },
  setup = function()
    Snacks.toggle.words():map("<leader>tW")

    require("which-key").add({
      {
        "<M-n>",
        function()
          Snacks.words.jump(vim.v.count1, true)
        end,
        desc = "Next Reference",
      },
      {
        "<M-p>",
        function()
          Snacks.words.jump(-vim.v.count1, true)
        end,
        desc = "Previous Reference",
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
