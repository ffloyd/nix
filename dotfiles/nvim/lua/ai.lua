-- Objective: Utilize AI to improve speed of development

local features = require("features")

features.add({
  "Github Copilot integration",
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
  "Show Copilot status in the statusline",
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
  "Copilot Chat (via CodeCompanion)",
  plugins = {
    {
      "olimorris/codecompanion.nvim",
      opts = function(_, opts)
        opts.adapters = opts.adapters or {}
        opts.adapters.copilot = require("codecompanion.adapters").extend("copilot", {
          schema = {
            model = {
              default = "claude-3.5-sonnet",
            },
          },
        })

        opts.extensions = opts.extensions or {}
        opts.extensions.mcphub = {
          callback = "mcphub.extensions.codecompanion",
          opts = {
            make_vars = true,
            make_slash_commands = true,
            show_result_in_chat = true,
          },
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
        { "<C-g><C-x>", ":<C-u>'<,'>GpChatNew split<cr>",  desc = "ChatNew split" },
        { "<C-g>a",     ":<C-u>'<,'>GpAppend<cr>",         desc = "Visual Append (after)" },
        { "<C-g>b",     ":<C-u>'<,'>GpPrepend<cr>",        desc = "Visual Prepend (before)" },
        { "<C-g>c",     ":<C-u>'<,'>GpChatNew<cr>",        desc = "Visual Chat New" },
        { "<C-g>g",     group = "generate into new .." },
        { "<C-g>ge",    ":<C-u>'<,'>GpEnew<cr>",           desc = "Visual GpEnew" },
        { "<C-g>gn",    ":<C-u>'<,'>GpNew<cr>",            desc = "Visual GpNew" },
        { "<C-g>gp",    ":<C-u>'<,'>GpPopup<cr>",          desc = "Visual Popup" },
        { "<C-g>gt",    ":<C-u>'<,'>GpTabnew<cr>",         desc = "Visual GpTabnew" },
        { "<C-g>gv",    ":<C-u>'<,'>GpVnew<cr>",           desc = "Visual GpVnew" },
        { "<C-g>i",     ":<C-u>'<,'>GpImplement<cr>",      desc = "Implement selection" },
        { "<C-g>n",     "<cmd>GpNextAgent<cr>",            desc = "Next Agent" },
        { "<C-g>p",     ":<C-u>'<,'>GpChatPaste<cr>",      desc = "Visual Chat Paste" },
        { "<C-g>r",     ":<C-u>'<,'>GpRewrite<cr>",        desc = "Visual Rewrite" },
        { "<C-g>s",     "<cmd>GpStop<cr>",                 desc = "GpStop" },
        { "<C-g>t",     ":<C-u>'<,'>GpChatToggle<cr>",     desc = "Visual Toggle Chat" },
        { "<C-g>w",     group = "Whisper" },
        { "<C-g>wa",    ":<C-u>'<,'>GpWhisperAppend<cr>",  desc = "Whisper Append" },
        { "<C-g>wb",    ":<C-u>'<,'>GpWhisperPrepend<cr>", desc = "Whisper Prepend" },
        { "<C-g>we",    ":<C-u>'<,'>GpWhisperEnew<cr>",    desc = "Whisper Enew" },
        { "<C-g>wn",    ":<C-u>'<,'>GpWhisperNew<cr>",     desc = "Whisper New" },
        { "<C-g>wp",    ":<C-u>'<,'>GpWhisperPopup<cr>",   desc = "Whisper Popup" },
        { "<C-g>wr",    ":<C-u>'<,'>GpWhisperRewrite<cr>", desc = "Whisper Rewrite" },
        { "<C-g>wt",    ":<C-u>'<,'>GpWhisperTabnew<cr>",  desc = "Whisper Tabnew" },
        { "<C-g>wv",    ":<C-u>'<,'>GpWhisperVnew<cr>",    desc = "Whisper Vnew" },
        { "<C-g>ww",    ":<C-u>'<,'>GpWhisper<cr>",        desc = "Whisper" },
        { "<C-g>x",     ":<C-u>'<,'>GpContext<cr>",        desc = "Visual GpContext" },
      },

      -- NORMAL mode mappings
      {
        mode = { "n" },
        nowait = true,
        remap = false,
        { "<C-g><C-t>", "<cmd>GpChatNew tabnew<cr>",   desc = "New Chat tabnew" },
        { "<C-g><C-v>", "<cmd>GpChatNew vsplit<cr>",   desc = "New Chat vsplit" },
        { "<C-g><C-x>", "<cmd>GpChatNew split<cr>",    desc = "New Chat split" },
        { "<C-g>a",     "<cmd>GpAppend<cr>",           desc = "Append (after)" },
        { "<C-g>b",     "<cmd>GpPrepend<cr>",          desc = "Prepend (before)" },
        { "<C-g>c",     "<cmd>GpChatNew<cr>",          desc = "New Chat" },
        { "<C-g>f",     "<cmd>GpChatFinder<cr>",       desc = "Chat Finder" },
        { "<C-g>g",     group = "generate into new .." },
        { "<C-g>ge",    "<cmd>GpEnew<cr>",             desc = "GpEnew" },
        { "<C-g>gn",    "<cmd>GpNew<cr>",              desc = "GpNew" },
        { "<C-g>gp",    "<cmd>GpPopup<cr>",            desc = "Popup" },
        { "<C-g>gt",    "<cmd>GpTabnew<cr>",           desc = "GpTabnew" },
        { "<C-g>gv",    "<cmd>GpVnew<cr>",             desc = "GpVnew" },
        { "<C-g>n",     "<cmd>GpNextAgent<cr>",        desc = "Next Agent" },
        { "<C-g>r",     "<cmd>GpRewrite<cr>",          desc = "Inline Rewrite" },
        { "<C-g>s",     "<cmd>GpStop<cr>",             desc = "GpStop" },
        { "<C-g>t",     "<cmd>GpChatToggle<cr>",       desc = "Toggle Chat" },
        { "<C-g>w",     group = "Whisper" },
        { "<C-g>wa",    "<cmd>GpWhisperAppend<cr>",    desc = "Whisper Append (after)" },
        { "<C-g>wb",    "<cmd>GpWhisperPrepend<cr>",   desc = "Whisper Prepend (before)" },
        { "<C-g>we",    "<cmd>GpWhisperEnew<cr>",      desc = "Whisper Enew" },
        { "<C-g>wn",    "<cmd>GpWhisperNew<cr>",       desc = "Whisper New" },
        { "<C-g>wp",    "<cmd>GpWhisperPopup<cr>",     desc = "Whisper Popup" },
        { "<C-g>wr",    "<cmd>GpWhisperRewrite<cr>",   desc = "Whisper Inline Rewrite" },
        { "<C-g>wt",    "<cmd>GpWhisperTabnew<cr>",    desc = "Whisper Tabnew" },
        { "<C-g>wv",    "<cmd>GpWhisperVnew<cr>",      desc = "Whisper Vnew" },
        { "<C-g>ww",    "<cmd>GpWhisper<cr>",          desc = "Whisper" },
        { "<C-g>x",     "<cmd>GpContext<cr>",          desc = "Toggle GpContext" },
      },

      -- INSERT mode mappings
      {
        mode = { "i" },
        nowait = true,
        remap = false,
        { "<C-g><C-t>", "<cmd>GpChatNew tabnew<cr>",   desc = "New Chat tabnew" },
        { "<C-g><C-v>", "<cmd>GpChatNew vsplit<cr>",   desc = "New Chat vsplit" },
        { "<C-g><C-x>", "<cmd>GpChatNew split<cr>",    desc = "New Chat split" },
        { "<C-g>a",     "<cmd>GpAppend<cr>",           desc = "Append (after)" },
        { "<C-g>b",     "<cmd>GpPrepend<cr>",          desc = "Prepend (before)" },
        { "<C-g>c",     "<cmd>GpChatNew<cr>",          desc = "New Chat" },
        { "<C-g>f",     "<cmd>GpChatFinder<cr>",       desc = "Chat Finder" },
        { "<C-g>g",     group = "generate into new .." },
        { "<C-g>ge",    "<cmd>GpEnew<cr>",             desc = "GpEnew" },
        { "<C-g>gn",    "<cmd>GpNew<cr>",              desc = "GpNew" },
        { "<C-g>gp",    "<cmd>GpPopup<cr>",            desc = "Popup" },
        { "<C-g>gt",    "<cmd>GpTabnew<cr>",           desc = "GpTabnew" },
        { "<C-g>gv",    "<cmd>GpVnew<cr>",             desc = "GpVnew" },
        { "<C-g>n",     "<cmd>GpNextAgent<cr>",        desc = "Next Agent" },
        { "<C-g>r",     "<cmd>GpRewrite<cr>",          desc = "Inline Rewrite" },
        { "<C-g>s",     "<cmd>GpStop<cr>",             desc = "GpStop" },
        { "<C-g>t",     "<cmd>GpChatToggle<cr>",       desc = "Toggle Chat" },
        { "<C-g>w",     group = "Whisper" },
        { "<C-g>wa",    "<cmd>GpWhisperAppend<cr>",    desc = "Whisper Append (after)" },
        { "<C-g>wb",    "<cmd>GpWhisperPrepend<cr>",   desc = "Whisper Prepend (before)" },
        { "<C-g>we",    "<cmd>GpWhisperEnew<cr>",      desc = "Whisper Enew" },
        { "<C-g>wn",    "<cmd>GpWhisperNew<cr>",       desc = "Whisper New" },
        { "<C-g>wp",    "<cmd>GpWhisperPopup<cr>",     desc = "Whisper Popup" },
        { "<C-g>wr",    "<cmd>GpWhisperRewrite<cr>",   desc = "Whisper Inline Rewrite" },
        { "<C-g>wt",    "<cmd>GpWhisperTabnew<cr>",    desc = "Whisper Tabnew" },
        { "<C-g>wv",    "<cmd>GpWhisperVnew<cr>",      desc = "Whisper Vnew" },
        { "<C-g>ww",    "<cmd>GpWhisper<cr>",          desc = "Whisper" },
        { "<C-g>x",     "<cmd>GpContext<cr>",          desc = "Toggle GpContext" },
      },
    })
  end,
})
