-- Objective: Utilize AI to improve speed of development

--- @module "snacks"

local features = require("features")

features.add({
  "AI assistants integration + Copilot next edit suggestions",
  after = { "which-key", "snacks", "lualine" },
  plugins = {
    {
      "folke/sidekick.nvim",
      opts = {
        nes = {
          -- originally 100 which is too fast and triggers too often
          debounce = 500,
        }
      }
    },
    {
      "nvim-lualine/lualine.nvim",
      opts = function(_, opts)
        -- Copilot status in lualine
        table.insert(opts.sections.lualine_x, 2, {
          function()
            local status = require("sidekick.status").get()

            if not status then
              return ""
            end

            -- Show busy icon if processing
            -- color will represent the status kind
            -- so we're aware of all kind + busy state combinations
            if status.busy then
              return ""
            end

            return status.kind == "Inactive" and ""
                or status.kind == "Error" and ""
                or status.kind == "Warning" and ""
                or ""
          end,
          color = function()
            local status = require("sidekick.status").get()

            if not status then
              return nil
            end

            local hlName = status.kind == "Inactive" and "Comment"
                or status.kind == "Error" and "DiagnosticError"
                or status.kind == "Warning" and "DiagnosticWarn"
                or status.kind == "Normal" and "DiagnosticOk"
                or "Special"

            -- to always use lualine's background color
            return { fg = require("utils").getFgHexColorFromHighlight(hlName) }
          end,
          cond = function()
            return require("sidekick.status").get() ~= nil
          end,
        })

        -- AI CLI status in lualine
        table.insert(opts.sections.lualine_x, 3, {
          function()
            return "󱚣" -- AI CLI session active
          end,

          cond = function()
            return #require("sidekick.status").cli() > 0
          end,

          color = function()
            return { fg = require("utils").getFgHexColorFromHighlight("Special") }
          end,
        })
      end
    }
  },
  setup = function()
    vim.lsp.enable("copilot")

    require("which-key").add({
      {
        "<C-l>",
        function()
          require("sidekick").nes_jump_or_apply()
        end,
        desc = "Copilot Next Edit Suggestion",
      },
      {
        "<A-l>",
        function()
          require("sidekick.nes").update()
        end,
        desc = "Copilot Next Edit Suggestion Update",
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
