-- Objective: Utilize AI to improve speed of development

local features = require("features")

features.add({
  "AI Code Completion with GitHub Copilot",
  id = "copilot",
  plugins = {
    {
      "zbirenbaum/copilot.lua",
      opts = {
        suggestion = {
          enabled = true,
          auto_trigger = true,
          keymap = {
            accept = "<M-S-l>",
            accept_line = "<M-l>",
            next = "<M-]>",
            prev = "<M-[>",
            dismiss = "<C-]>",
          },
        },
        filetypes = {
          markdown = true,
        },
        panel = { enabled = false },
      },
    },
  },
})

features.add({
  "Copilot Status Integration for Lualine",
  after = { "copilot", "lualine" },
  plugins = {
    { "AndreM222/copilot-lualine" },
    {
      "nvim-lualine/lualine.nvim",
      opts = function(_, opts)
        table.insert(opts.sections.lualine_x, 2, {
          "copilot",
          show_colors = true,
          symbols = {
            status = {
              icons = {
                enabled = "",
                sleep = "", -- auto-trigger disabled
                disabled = "",
                warning = "",
                unknown = "",
              },
            },
          },
        })
      end,
    },
  },
})

features.add({
  "AI Chat Assistant with CodeCompanion",
  id = "codecompanion",
  after = { "mcphub", "blink", "fidget", "which-key", "copilot" },
  plugins = {
    {
      "olimorris/codecompanion.nvim",
      opts = function(_, _)
        return {
          adapters = {
            copilot = require("codecompanion.adapters").extend("copilot", {
              schema = {
                model = {
                  default = "claude-3.5-sonnet",
                },
              },
            }),
            anthropic = require("codecompanion.adapters").extend("anthropic",
              {
                env = {
                  api_key = "cmd:pass anthropic/api_key"
                },
              }),
            openai = require("codecompanion.adapters").extend("openai", {
              env = {
                api_key = "cmd:pass openai/api_key"
              },
            }),
            tavily = require("codecompanion.adapters").extend("tavily", {
              env = {
                api_key = "cmd:pass tavily/api_key"
              },
            })
          },
          extensions = {
            mcphub = {
              callback = "mcphub.extensions.codecompanion",
              opts = {
                make_vars = true,
                make_slash_commands = true,
                show_result_in_chat = true,
              },
            }
          }
        }
      end,
      dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
        "j-hui/fidget.nvim",
        "ravitemer/mcphub.nvim",
        {
          "saghen/blink.cmp",
          opts = function(_, opts)
            opts.sources = opts.sources or {}
            opts.sources.per_filetype = opts.sources.per_filetype or {}
            opts.sources.per_filetype.codecompanion = { "codecompanion" }
          end,
        },
      },
    },
  },
  setup = function()
    require("which-key").add({
      { "<leader>ac",  group = "Code Companion",        mode = { "n", "v" } },
      { "<leader>acc", "<cmd>CodeCompanionChat<cr>",    desc = "Chat" },
      { "<leader>aca", "<cmd>CodeCompanionActions<cr>", desc = "Action" },
      { "<leader>aci", "<cmd>CodeCompanion<cr>",        desc = "Inline",    mode = { "n", "v" } },
    })

    require("codecompanion-fidget-spinner"):init()
  end,
})

features.add({
  "Model Communication Protocol (MCP)",
  id = "mcphub",
  after = { "which-key" },
  plugins = {
    {
      "ravitemer/mcphub.nvim",
      dependencies = {
        "nvim-lua/plenary.nvim", -- Required for Job and HTTP requests
      },
      -- uncomment the following line to load hub lazily
      --cmd = "MCPHub",  -- lazy load
      build = "npm install -g mcp-hub@latest", -- Installs required mcp-hub npm module
      -- uncomment this if you don't want mcp-hub to be available globally or can't use -g
      -- build = "bundled_build.lua",  -- Use this and set use_bundled_binary = true in opts  (see Advanced configuration)
      opts = {},
    },
  },
  setup = function()
    require("which-key").add({
      {
        "<leader>am",
        "<cmd>MCPHub<cr>",
        desc = "MCP Hub",
      },
    })
  end,
})

features.add({
  "Claude Code integration",
  id = "claudecode",
  after = { "which-key", "snacks" },
  plugins = {
    {
      "coder/claudecode.nvim",
      dependencies = { "folke/snacks.nvim" },
      config = true,
      keys = {
        { "<leader>aa",  nil,                              desc = "Claude Code" },
        { "<leader>aaa", "<cmd>ClaudeCode<cr>",            desc = "Toggle Claude" },
        { "<leader>aaf", "<cmd>ClaudeCodeFocus<cr>",       desc = "Focus Claude" },
        { "<leader>aar", "<cmd>ClaudeCode --resume<cr>",   desc = "Resume Claude" },
        { "<leader>aac", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
        { "<leader>aab", "<cmd>ClaudeCodeAdd %<cr>",       desc = "Add current buffer" },
        { "<leader>aas", "<cmd>ClaudeCodeSend<cr>",        desc = "Send to Claude",    mode = "v" },
        -- {
        --   "<leader>aaS",
        --   "<cmd>ClaudeCodeTreeAdd<cr>",
        --   desc = "Add file",
        --   ft = { "NvimTree", "neo-tree", "oil" },
        -- },
        -- Diff management
        { "<leader>aay", "<cmd>ClaudeCodeDiffAccept<cr>",  desc = "Accept diff" },
        { "<leader>aan", "<cmd>ClaudeCodeDiffDeny<cr>",    desc = "Deny diff" },
      },
    }
  }
})
