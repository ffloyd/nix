--
-- Autocomplete & LSP related stuff
--
return {
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "folke/lazydev.nvim",
      "hrsh7th/cmp-buffer",
      "amarakon/nvim-cmp-buffer-lines",
      "hrsh7th/cmp-calc",
      "uga-rosa/cmp-dictionary",
      "f3fora/cmp-spell",
      "hrsh7th/cmp-nvim-lsp-signature-help",
    },
    config = function()
      local cmp = require("cmp")

      local dabbrev_cmp = {
        name = "buffer",
        option = {
          get_bufnrs = vim.api.nvim_list_bufs,
        },
      }

      local lines_cmp = {
        name = "buffer-lines",
        option = {
          line_numbers = true,
        },
      }

      local calc_cmp = { name = "calc" }
      local spell_cmp = { name = "spell" }

      require("cmp_dictionary").setup({
        paths = {
          "/usr/share/dict/words",
        },
        exact_length = 2,
      })
      local dict_cmp = { name = "dictionary", keyword_length = 2 }

      cmp.setup({
        snippet = {
          expand = function(args)
            vim.snippet.expand(args.body) -- For native neovim snippets (Neovim v0.10+)
          end,
        },
        window = {
          -- completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = {
            i = cmp.mapping.scroll_docs(-4),
          },
          ["<C-f>"] = {
            i = cmp.mapping.scroll_docs(4),
          },
          ["<Tab>"] = {
            i = cmp.mapping.confirm({ select = true }),
          },
          ["<C-Tab><C-Tab>"] = { i = cmp.mapping.complete() },
          ["<C-Tab>c"] = { i = cmp.mapping.complete({ config = { sources = { calc_cmp } } }) },
          ["<C-Tab>d"] = { i = cmp.mapping.complete({ config = { sources = { dabbrev_cmp } } }) },
          ["<C-Tab>l"] = { i = cmp.mapping.complete({ config = { sources = { lines_cmp } } }) },
          ["<C-Tab>s"] = { i = cmp.mapping.complete({ config = { sources = { spell_cmp } } }) },
          ["<C-Tab>w"] = { i = cmp.mapping.complete({ config = { sources = { dict_cmp } } }) },
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "nvim_lsp_signature_help" },
          {
            name = "lazydev",
            group_index = 0, -- set group index to 0 to skip loading LuaLS completions
          },
        }, {
          dabbrev_cmp,
        }),
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
    },
    lazy = false,
    config = function()
      local lspconfig = require("lspconfig")

      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      lspconfig.dockerls.setup({
        capabilities = capabilities,
      })

      lspconfig.gopls.setup({
        capabilities = capabilities,
      })

      lspconfig.lua_ls.setup({
        capabilities = capabilities,
      })

      lspconfig.lexical.setup({
        capabilities = capabilities,
        cmd = { "lexical" },
      })

      lspconfig.nixd.setup({
        capabilities = capabilities,
      })

      lspconfig.pyright.setup({
        capabilities = capabilities,
      })

      lspconfig.terraformls.setup({
        capabilities = capabilities,
      })

      lspconfig.ts_ls.setup({
        capabilities = capabilities,
      })
    end,
  },
  {
    "folke/lazydev.nvim", -- LuaLS wrapper for editing NeoVim configs
    ft = "lua", -- only load on lua files
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "luvit-meta/library", words = { "vim%.uv" } },
      },
    },
  },
  { "Bilal2453/luvit-meta", lazy = true }, -- optional `vim.uv` typings
}
