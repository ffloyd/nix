-- Objective: Utilize AI to improve speed of development

--- @module "snacks"

local features = require("features")

features.add({
  "AI assistants integration + Copilot next edit suggestions",
  after = { "which-key", "snacks" },
  plugins = {
    {
      "folke/sidekick.nvim",
      opts = {
        nes = {
          -- originally 100 which is too fast and triggers too often
          debounce = 500,
          -- originally had 'User SidekickNesDone', but it fires even in insert mode
          events = { "ModeChanged *:n", "TextChanged" },
        }
      }
    }
  },
  setup = function()
    vim.lsp.enable('copilot')

    require("which-key").add({
      {
        "<C-/>",
        function()
          require("sidekick").nes_jump_or_apply()
        end,
      },
      {
        "<c-.>",
        function() require("sidekick.cli").toggle() end,
        desc = "Sidekick Toggle",
        mode = { "n", "t", "i", "x" },
      },
      { "<leader>aa", group = "AI Sidekick", mode = { "n", "x" } },
      {
        "<leader>aaa",
        function() require("sidekick.cli").toggle() end,
        desc = "Sidekick Toggle CLI",
      },
      {
        "<leader>aas",
        function() require("sidekick.cli").select({ filter = { installed = true } }) end,
        desc = "Select CLI",
      },
      {
        "<leader>aad",
        function() require("sidekick.cli").close() end,
        desc = "Detach a CLI Session",
      },
      {
        "<leader>aat",
        function() require("sidekick.cli").send({ msg = "{this}" }) end,
        mode = { "x", "n" },
        desc = "Send This",
      },
      {
        "<leader>aaf",
        function() require("sidekick.cli").send({ msg = "{file}" }) end,
        desc = "Send File",
      },
      {
        "<leader>aav",
        function() require("sidekick.cli").send({ msg = "{selection}" }) end,
        mode = { "x" },
        desc = "Send Visual Selection",
      },
      {
        "<leader>aap",
        function() require("sidekick.cli").prompt() end,
        mode = { "n", "x" },
        desc = "Sidekick Select Prompt",
      },
      -- Example of a keybinding to open assistant directly
      {
        "<leader>aac",
        function() require("sidekick.cli").toggle({ name = "claude", focus = true }) end,
        desc = "Sidekick Toggle Claude",
      },
      {
        "<leader>aao",
        function() require("sidekick.cli").toggle({ name = "opencode", focus = true }) end,
        desc = "Sidekick Toggle Open",
      },
    })

    Snacks.toggle.new({
      name = "Next Edit Suggestion",
      get = function()
        return require("sidekick.nes").enabled
      end,
      set = function(state)
        require("sidekick.nes").enable(state)
      end
    }):map("<leader>TN")
  end
})
