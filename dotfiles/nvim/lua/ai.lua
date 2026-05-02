-- Objective: Utilize AI to improve speed of development

--- @module "snacks"

local features = require("features")

features.add({
  "OpenCode integration",
  after = { "which-key", "snacks" },
  plugins = {
    {
      "nickjvandyke/opencode.nvim",
      version = "*",
    }
  },
  setup = function()
    -- Required by opencode.nvim for file reload events when opencode edits files
    vim.o.autoread = true

    local opencode_cmd = "opencode --port"

    local snacks_term = require("snacks.terminal")
    local opencode = require("opencode")

    ---@type snacks.terminal.Opts
    local opencode_terminal_opts = {
      win = {
        position = 'right',
        -- By default we do not want to focus on terminal each time it's shown.
        -- This should be an opt-in behaviour.
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
          snacks_term.open(opencode_cmd, opencode_terminal_opts)
        end,
        stop = function()
          snacks_term.get(opencode_cmd, opencode_terminal_opts):close()
        end,
        toggle = function()
          snacks_term.toggle(opencode_cmd, opencode_terminal_opts)
        end,
      },
    }

    local function get_opencode_term()
      local opts = vim.tbl_deep_extend('force', opencode_terminal_opts, { create = false })
      return snacks_term.get(opencode_cmd, opts)
    end

    -- Toggle OpenCode with focus on its window
    local function toggle_with_focus()
      opencode.toggle() -- this will start terminal

      local term = get_opencode_term()

      -- valid is false when terminal has no window
      if term:valid() then
        term:focus()
      end
    end

    -- Shows OpenCode if hidded, then "asks" without submit
    local function ask_with_term()
      local term = get_opencode_term()

      if not term or not term:valid() then
        opencode.toggle()
      end

      opencode.ask("@this ")
    end

    require("which-key").add({
      {
        "<c-.>",
        toggle_with_focus,
        desc = "Toggle OpenCode (with focus)",
        mode = { "n", "t", "i", "x" },
      },
      {
        "<c-,>",
        ask_with_term,
        desc = "Ask OpenCode (ensures UI is visible)",
        mode = { "n", "t", "i", "x" },
      },
      { "<leader>aa", group = "OpenCode (AI)", mode = { "n", "x" } },
      {
        "<leader>aaa",
        function() opencode.ask("", { submit = true }) end,
        desc = "Ask",
      },
      {
        "<leader>aaA",
        function() opencode.ask() end,
        desc = "Ask (no submit)",
      },
      {
        "<leader>aac",
        function() opencode.command("agent.cycle") end,
        desc = "Cycle Agent",
      },
      {
        "<leader>aaC",
        function() opencode.command("session.compact") end,
        desc = "Compact Session",
      },
      {
        "<leader>aa<Space>",
        function() opencode.select() end,
        desc = "Action Picker",
      },
      {
        "<leader>aa<CR>",
        function() opencode.command('prompt.submit') end,
        desc = "Submit Current Prompt"
      },
      {
        "go",
        ---@diagnostic disable-next-line: redundant-return-value
        function() return opencode.operator("@this ") end,
        desc = "Send range to OpenCode",
        mode = { "n", "x" },
        expr = true,
      },
      {
        "goo",
        ---@diagnostic disable-next-line: redundant-return-value
        function() return opencode.operator("@this ") .. "_" end,
        desc = "Send line to OpenCode",
        mode = "n",
        expr = true,
      },
    })
  end
})
