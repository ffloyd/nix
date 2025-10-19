-- Objective: Adopt maximum from snacks.nvim in order to elevate overall experience.
--
-- "It's not NeoVim, it's FolkeVim!" said one of my friends.
-- Snacks.nvim is a collection of plugins and configurations that enhance the Neovim experience.
-- It so cool, that I decided to adopt most of it as a "new default" rather than thinking about it as 3rd party extensions.
--
-- This file covers most of Snacks usage in my Neovim setup, but not all of it.

local features = require("features")

local merger = features.merger
local combine = features.combine

features.add({
  "Enable trivial Snacks.nvim improvements",
  id = "snacks",
  plugins = {
    {
      "folke/snacks.nvim",
      priority = 1000,
      lazy = false,
      ---@type snacks.Config
      opts = {
        bigfile = {
          enabled = true,
          notify = true,
        },
        dashboard = {
          example = "advanced",
        },
      },
    },
  },
})

-- TODO: animate (toggle global animations)
-- TODO: bufdelete
-- TODO: debug
-- TODO: dim (make toggle)
-- TODO: explorer (also find a way to open explorer local to current git repo using Snacks.git.get_root())
-- TODO: git (Snacks.git.blame_line())
-- TODO: gitbrowse (consider using it for <leader>gy/<leader>gY)
-- TODO: image (add Snacks.image.hover() to mappings)
-- TODO: indent (driven by toggle, disable animations)

-- This makes direct calls to Snacks.* functions recognized by the LSP.
---@module "snacks"

features.add({
  "Better UI elements from Snacks",
  after = { "snacks" },
  plugins = {
    {
      "folke/snacks.nvim",
      opts = combine({
        merger("statuscolumn", {
          enabled = true,
          folds = {
            open = true,
            git_hl = true,
          },
        }),
        merger("input", { enabled = true }),
        merger("notifier", { enabled = true }),
        merger("picker",
          --- @type snacks.picker.Config
          {
            enabled = true,
            ui_select = true,
            actions = {
              -- Why: Enables sending picker selections to Sidekick AI assistant
              -- without manual file path copying or content extraction
              sidekick_send = function(...)
                return require("sidekick.cli.snacks").send(...)
              end
            },
            win = {
              input = {
                keys = {
                  ["<A-a>"] = {
                    "sidekick_send",
                    mode = { "n", "i" }
                  }
                }
              }
            }
          }
        ),
      }),
    },
  },
})

features.add({
  "Enable fancy fuzzy finders",
  after = { "which-key", "snacks" },
  plugins = {
    {
      "folke/snacks.nvim",
    },
  },
  setup = function()
    require("which-key").add({
      -- Top-level finders
      {
        "<leader>fb",
        function()
          Snacks.picker.buffers()
        end,
        desc = "Buffer",
      },
      {
        "<leader>fc",
        function()
          ---@diagnostic disable-next-line: assign-type-mismatch
          Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
        end,
        desc = "Config File",
      },
      {
        "<leader>ff",
        function()
          Snacks.picker.files({ cwd = vim.fn.expand("%:p:h") })
        end,
        desc = "File (current buffer directory)",
      },
      {
        "<leader>fg",
        function()
          Snacks.picker.grep()
        end,
        desc = "Grep Files",
      },
      {
        "<leader>fG",
        function()
          Snacks.picker.git_files()
        end,
        desc = "Git File",
      },
      {
        "<leader>fl",
        function()
          Snacks.picker.lines()
        end,
        desc = "Line",
      },
      {
        "<leader>fr",
        function()
          Snacks.picker.recent()
        end,
        desc = "Recent",
      },
    })
  end,
})

features.add({
  "Search lines by `C-SPC C-SPC` and files by `SPC SPC`",
  after = { "which-key", "snacks" },
  setup = function()
    require("which-key").add({
      {
        "<C-Space><C-Space>",
        function()
          Snacks.picker.lines()
        end,
        desc = "Find Line",
      },
      {
        "<Space><Space>",
        function()
          Snacks.picker.files()
        end,
        desc = "Find File",
      },
    })
  end,
})

features.add({
  "Search commands by <leader>:",
  after = { "which-key", "snacks" },
  setup = function()
    require("which-key").add({
      {
        "<leader>:",
        function()
          Snacks.picker.command_history()
        end,
        desc = "Command History",
      },
    })
  end,
})

features.add({
  "Use Snacks.debug",
  after = { "snacks" },
  setup = function()
    _G.dd = function(...)
      Snacks.debug.inspect(...)
    end
    _G.bt = function()
      Snacks.debug.backtrace()
    end
    vim.print = _G.dd
  end,
})

features.add({
  "Add Snacks.nvim toggles",
  after = { "snacks" },
  setup = function()
    Snacks.toggle.option("spell"):map("<leader>Ts")
    Snacks.toggle.indent():map("<leader>Ti")
    Snacks.toggle.line_number():map("<leader>Tn")
  end,
})

features.add({
  "Rename a file with Snacks",
  after = { "which-key", "snacks" },
  setup = function()
    require("which-key").add({
      {
        "<leader>br",
        function()
          Snacks.rename.rename_file()
        end,
        desc = "Rename File",
      },
    })
  end,
})

features.add({
  "Toggle terminal",
  after = { "which-key", "snacks" },
  setup = function()
    require("which-key").add({
      {
        "<leader>at",
        function()
          Snacks.terminal.toggle(nil, {
            start_insert = true,
            auto_close = true,
            -- to have a more consistent experience when jumping between windows and tabs
            auto_insert = false,
          })
        end,
        desc = "Terminal",
      },
    })
  end,
})

features.add({
  "File Explorer (snacks.nvim)",
  after = { "which-key", "snacks" },
  plugins = {
    {
      "folke/snacks.nvim",
      opts = combine({
        merger("explorer", {
          replace_netrw = true,
        }),
        merger("picker", {
          sources = {
            explorer = {
              layout = { preset = "default", preview = false },
              auto_close = true,
              jump = { close = true },
            },
          },
        }),
      }),
    },
  },
  setup = function()
    require("which-key").add({
      {
        "<leader>ue",
        function()
          Snacks.explorer.open()
        end,
        desc = "Explorer (snacks.nvim)",
      },
    })
  end,
})

features.add({
  "List recent notifications",
  after = { "which-key", "snacks" },
  plugins = {
    {
      "folke/snacks.nvim",
      opts = merger("notifier", { enabled = true }),
    },
  },
  setup = function()
    require("which-key").add({
      {
        "<leader>un",
        function()
          Snacks.notifier.show_history()
        end,
        desc = "List Notifications",
      },
    })
  end,
})
