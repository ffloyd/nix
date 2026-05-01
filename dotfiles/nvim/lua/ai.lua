-- Objective: Utilize AI to improve speed of development

--- @module "snacks"

local features = require("features")

features.add({
  "AI assistants integration",
  after = { "which-key", "snacks" },
  plugins = {
    {
      -- "nickjvandyke/opencode.nvim",
      "ffloyd/opencode.nvim",
      branch = "fix-for-nix",
      version = "*",
    }
  },
  setup = function()
    -- Required by opencode.nvim for file reload events when opencode edits files
    vim.o.autoread = true

    local opencode_cmd = "opencode --port"

    ---@type snacks.terminal.Opts
    local snacks_terminal_opts = {
      win = {
        position = 'right',
        enter = false,
        on_win = function(win)
          -- Set up keymaps and cleanup for an arbitrary terminal
          require('opencode.terminal').setup(win.win)
        end,
      },
    }

    ---@type opencode.Opts
    vim.g.opencode_opts = {
      server = {
        start = function()
          require('snacks.terminal').open(opencode_cmd, snacks_terminal_opts)
        end,
        stop = function()
          require('snacks.terminal').get(opencode_cmd, snacks_terminal_opts):close()
        end,
        toggle = function()
          require('snacks.terminal').toggle(opencode_cmd, snacks_terminal_opts)
        end,
      },
    }

    require("which-key").add({
      {
        "<c-.>",
        function() require("opencode").toggle() end,
        desc = "OpenCode Toggle",
        mode = { "n", "t", "i", "x" },
      },
      { "<leader>aa", group = "AI OpenCode", mode = { "n", "x" } },
      {
        "<leader>aaa",
        function() require("opencode").ask("@this: ", { submit = true }) end,
        desc = "Ask OpenCode",
      },
      {
        "<leader>aas",
        function() require("opencode").select() end,
        desc = "Select OpenCode Action",
      },
      {
        "<leader>aaS",
        function() require("opencode").select_server() end,
        desc = "Select OpenCode Action",
      },
      {
        "<leader>aat",
        function() require("opencode").toggle() end,
        desc = "Toggle OpenCode",
      },
    })
  end
})
