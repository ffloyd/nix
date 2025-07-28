-- This configuration is a slightly different than the most other configurations.
-- Instead of trying to organize everything in a single file,
-- or splitting it into multiple files by categories,
-- or organize by plugins or plugin groups,
-- this configuration has given up on such approaches.
--
-- Instead, it starts as a single file that made of multiple features.
-- Feature is not just a plugin(s) configuration, but something you want to achieve using the set of plugins and configs.
--
-- Over time features will be piling up in the file.
-- Wait fot the moment when it becomes really inconvinient and distracting,
-- avoid perfectionistic desire to organize everything in a perfect way!
--
-- When the moment comes, start extracting groups of features into separate files.
-- Start with one and just require it in the main file.
--
-- When introducing a new file, avoid thinking about it as a category (UI, LSP, AI, etc).
-- Instead, organize by objective.
-- A good examples: "Utilize AI to improve my productivity" (`ai.lua`), "Make code comfortable to read" (`readability.lua`), etc.
-- Explain objective in the beginning of the file inside a comment.
--
-- Such approach is inspired by OKR (Objectives and Key Results) methodology.
-- It's not applied here as is: instead of having key results that are measurable, we have features.
-- It can be called "Objective-to-Features" Configuration style.

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- use features-centric approach instead of plugin-centric
local features = require("features")

require("ai")
require("folkevim")
require("lang-tools")

features.add({
  "Use a colorscheme that inspired by the Kanagawa wave",
  id = "kanagawa",
  plugins = {
    {
      "rebelot/kanagawa.nvim",
      name = "kanagawa",
      priority = 1000,
      opts = {
        colors = {
          theme = {
            all = {
              ui = {
                -- disable separate fringe background
                bg_gutter = "none",
              },
            },
          },
        },
      },
    },
  },
  setup = function()
    vim.cmd.colorscheme("kanagawa-wave")
  end,
})

features.add({
  "Show available keybindings in a popup as you type",
  id = "which-key",
  plugins = {
    {
      "folke/which-key.nvim",
      event = "VeryLazy",
      dependencies = {
        "nvim-tree/nvim-web-devicons",
      },
      opts = {
        preset = "modern",
        delay = 500,
      },
    },
  },
})

features.add({
  "Top-level leader keymap groups",
  after = { "which-key" },
  setup = function()
    require("which-key").add({
      { "<leader>?", group = "Help" },
      { "<leader>a", group = "Apps/AI" },
      { "<leader>b", group = "Buffer" },
      { "<leader>e", group = "Editor Helpers" },
      { "<leader>f", group = "Finders" },
      { "<leader>g", group = "Git/VCS" },
      { "<leader>l", group = "Lang Tools" },
      { "<leader>s", group = "Search/Replace" },
      { "<leader>T", group = "Toggle" },
      { "<leader>t", group = "Tabs" },
      { "<leader>u", group = "Utils" },
      { "<leader>x", group = "eXplore" },
    })
  end,
})

features.add({
  "Enable tree-sitter usage for all supported syntaxes",
  plugins = {
    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      config = function()
        local config = require("nvim-treesitter.configs")

        ---@diagnostic disable-next-line: missing-fields
        config.setup({
          ensure_installed = "all",
          auto_install = false,
          highlight = { enable = true },
          incremental_selection = { enable = true },
          indent = { enable = true },
        })

        -- also use for folding
        vim.o.foldmethod = "expr"
        vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
      end,
    },
  },
})

features.add({
  "2-space autoindentation by default",
  setup = function()
    vim.o.softtabstop = 2
    vim.o.shiftwidth = 2
    vim.o.expandtab = true
  end,
})

features.add({
  "Autocompletion with Blink",
  id = "blink",
  plugins = {
    {
      "saghen/blink.cmp",
      dependencies = {
        "rafamadriz/friendly-snippets",
        "saghen/blink.compat",
      },
      version = "*",
      ---@module "blink-cmp"
      ---@type blink.cmp.Config
      opts = {
        keymap = { preset = "super-tab" },
        appearance = {
          use_nvim_cmp_as_default = true,
          nerd_font_variant = "mono",
        },
        sources = {
          default = { "lsp", "path", "snippets", "buffer" },
          providers = {},
        },
      },
    },
  },
})

features.add({
  "LazyDev <-> Blink integration",
  plugins = {
    {
      "saghen/blink.cmp",
      dependencies = "folke/lazydev.nvim",
      opts = function(_, opts)
        table.insert(opts.sources.default, 1, "lazydev")

        opts.sources.providers.lazydev = {
          name = "LazyDev",
          module = "lazydev.integrations.blink",
          -- make lazydev completions top priority (see `:h blink.cmp`)
          score_offset = 100,
        }
      end,
    },
  },
})


features.add({
  "Discover top-level keybindings",
  after = { "which-key" },
  setup = function()
    require("which-key").add({
      {
        "<leader>?/",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
      {
        "<leader>??",
        function()
          require("which-key").show({ global = true })
        end,
        desc = "Global Keymaps (which-key)",
      },
    })
  end,
})

features.add({
  "Do not fold when open a file",
  setup = function()
    -- this soulution will require to use `zR` once before using `zm/zr`.
    vim.o.foldlevel = 99
  end,
})

features.add({
  "Git interface like EMACS's Magit",
  plugins = {
    {
      "NeogitOrg/neogit",
      dependencies = {
        "nvim-lua/plenary.nvim",  -- required
        "sindrets/diffview.nvim", -- optional - Diff integration
      },
      opts = {
        disable_insert_on_commit = true,
        integrations = {
          diffview = true,
        },
      },
      keys = {
        {
          "<leader>gg",
          function()
            require("neogit").open()
          end,
          desc = "NeoGit",
        },
      },
    },
  },
})

features.add({
  "Autopairs",
  plugins = {
    {
      "windwp/nvim-autopairs",
      event = "InsertEnter",
      opts = {},
    },
  },
})

features.add({
  "Buffer Navigation & Deletion",
  after = { "which-key", "snacks" },
  setup = function()
    require("which-key").add({
      {
        "<leader>bn",
        "<cmd>bnext<cr>",
        desc = "Next Buffer",
      },
      {
        "<leader>bp",
        "<cmd>bprevious<cr>",
        desc = "Previous Buffer",
      },
      {
        "<leader>bk",
        function()
          Snacks.bufdelete.delete()
        end,
        desc = "Close Buffer",
      },
      {
        "<leader>bK",
        function()
          Snacks.bufdelete.all()
        end,
        desc = "Close All Buffers",
      },
      {
        "<leader>bb",
        function()
          Snacks.picker.buffers()
        end,
        desc = "Find Buffer",
      },
    })
  end,
})

features.add({
  "Fancy global statusline",
  id = "lualine",
  plugins = {
    {
      "nvim-lualine/lualine.nvim",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      opts = {
        options = {
          globalstatus = true,
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { { "filename", path = 1 } },
          lualine_x = {
            { "lsp_status", ignore_lsp = { "copilot" } },
            "encoding",
            "fileformat",
            "filetype",
          },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      },
    },
  },
})

features.add({
  "Show file name in a buffer corner",
  after = { "kanagawa" },
  plugins = {
    {
      "b0o/incline.nvim",
      init = function()
        vim.o.laststatus = 3
      end,
      opts = {
        window = {
          padding = 0,
          margin = { horizontal = 0 },
        },
        render = function(props)
          local devicons = require("nvim-web-devicons")
          local bg_color = require("kanagawa.colors").setup().theme.ui.bg_p1

          local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
          if filename == "" then
            filename = "[No Name]"
          end

          local ft_icon, ft_color = devicons.get_icon_color(filename)
          local modified = vim.bo[props.buf].modified

          return {
            ft_icon and { " ", ft_icon, " ", guifg = ft_color } or "",
            " ",
            { filename, gui = modified and "bold,italic" or "bold" },
            " ",
            guibg = bg_color,
          }
        end,
      },
    },
  },
})

features.add({
  "Tabs control",
  plugins = {
    {
      "nanozuki/tabby.nvim",
      dependencies = {
        "nvim-tree/nvim-web-devicons",
      },
      opts = {
        preset = "tab_only",
        option = {
          nerdfont = true,
        },
      },
    },
  },
  setup = function()
    require("which-key").add({
      {
        "<leader>tn",
        "<cmd>tabnext<cr>",
        desc = "Next Tab",
      },
      {
        "<leader>tp",
        "<cmd>tabprevious<cr>",
        desc = "Previous Tab",
      },
      {
        "<leader>tl",
        "<cmd>+tabmove<cr>",
        desc = "Move Tab Right",
      },
      {
        "<leader>th",
        "<cmd>-tabmove<cr>",
        desc = "Move Tab Left",
      },
      {
        "<leader>tt",
        "<cmd>$tabnew<cr>",
        desc = "New Tab",
      },
      {
        "<leader>tk",
        "<cmd>tabclose<cr>",
        desc = "Close Tab",
      },
      {
        "<leader>tr",
        function()
          local newname = vim.fn.input("Rename tab to: ")
          require("tabby").tab_rename(newname)
        end,
        desc = "Rename Tab",
      },
      {
        "<leader>to",
        "<cmd>tabonly<cr>",
        desc = "Close Other Tabs",
      },
    })
  end,
})

features.add({
  "Show git status in the sign column",
  plugins = {
    {
      "lewis6991/gitsigns.nvim",
      opts = {
        signs_staged_enable = false,
      },
    },
  },
  setup = function()
    Snacks.toggle
        .new({
          name = "Git Signs",
          get = function()
            return require("gitsigns.config").config.signcolumn
          end,
          set = function(state)
            require("gitsigns").toggle_signs(state)
          end,
        })
        :map("<leader>Tg")
  end,
})

features.add({
  "Git hunks/diffs in-buffer navigation and control",
  after = { "which-key" },
  plugins = {
    { "lewis6991/gitsigns.nvim" },
  },
  setup = function()
    require("which-key").add({
      {
        "<leader>gn",
        function()
          require("gitsigns").nav_hunk("next")
        end,
        desc = "Next Hunk",
      },
      {
        "<leader>gp",
        function()
          require("gitsigns").nav_hunk("prev")
        end,
        desc = "Previous Hunk",
      },
      {
        "<leader>gv",
        function()
          require("gitsigns").preview_hunk()
        end,
        desc = "Preview Hunk",
      },
      {
        "<leader>gd",
        function()
          require("gitsigns").diffthis()
        end,
        desc = "Diff Current File",
      },
      {
        "<leader>gs",
        function()
          require("gitsigns").stage_hunk()
        end,
        mode = "n",
        desc = "Stage Hunk",
      },
      {
        "<leader>gs",
        function()
          require("gitsigns").stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end,
        mode = "v",
        desc = "Stage Lines",
      },
      {
        "<leader>gr",
        function()
          require("gitsigns").reset_hunk()
        end,
        mode = "n",
        desc = "Reset Hunk",
      },
      {
        "<leader>gr",
        function()
          require("gitsigns").reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end,
        mode = "v",
        desc = "Reset Lines",
      },
      {
        "<leader>gu",
        function()
          require("gitsigns").undo_stage_hunk()
        end,
        desc = "Undo Stage Hunk",
      },
    })
  end,
})

features.add({
  "BLAME!",
  plugins = {
    { "lewis6991/gitsigns.nvim" },
  },
  setup = function()
    Snacks.toggle
        .new({
          name = "Current Line Blame",
          get = function()
            return require("gitsigns.config").config.current_line_blame
          end,
          set = function(state)
            require("gitsigns").toggle_current_line_blame(state)
          end,
        })
        :map("<leader>Tb")

    require("which-key").add({
      {
        "<leader>gb",
        function()
          require("gitsigns").blame_line()
        end,
        desc = "Blame Line",
      },
      {
        "<leader>gB",
        function()
          require("gitsigns").blame()
        end,
        desc = "Blame",
      },
    })
  end,
})

features.add({
  "Better w/e/b navigation",
  plugins = {
    {
      "chrisgrieser/nvim-spider",
      keys = {
        {
          "w",
          "<cmd>lua require('spider').motion('w')<CR>",
          mode = { "n", "o", "x" },
        },
        {
          "e",
          "<cmd>lua require('spider').motion('e')<CR>",
          mode = { "n", "o", "x" },
        },
        {
          "b",
          "<cmd>lua require('spider').motion('b')<CR>",
          mode = { "n", "o", "x" },
        },
      },
    },
  },
})

features.add({
  "More intiutive integration with system clipboard",
  setup = function()
    vim.opt.clipboard:append("unnamedplus")
  end,
})

features.add({
  "Adjust spell checking",
  setup = function()
    vim.o.spelllang = "en_us"
  end,
})

features.add({
  "More granular undo for text in insert mode",
  setup = function()
    -- https://stackoverflow.com/questions/2895551/how-do-i-get-fine-grained-undo-in-vim
    vim.cmd.inoremap("<Space>", "<Space><C-g>u")
  end,
})

features.add({
  "Convinient search/replace UI (grug-far)",
  plugins = {
    {
      "MagicDuck/grug-far.nvim",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      ---@type grug.far.Options
      ---@diagnostic disable-next-line: missing-fields
      opts = {
        ---@diagnostic disable-next-line: missing-fields
        engines = {
          ---@diagnostic disable-next-line: missing-fields
          astgrep = {
            path = "ast-grep",
          },
        },
      },
    },
  },
  setup = function()
    local gf = require("grug-far")

    local function search_word_ripgrep()
      gf.open({ prefills = { search = vim.fn.expand("<cword>") }, engine = "ripgrep" })
    end

    local function search_file_ripgrep()
      gf.open({ prefills = { paths = vim.fn.expand("%") }, engine = "ripgrep" })
    end

    local function search_file_astgrep()
      gf.open({ prefills = { paths = vim.fn.expand("%") }, engine = "astgrep" })
    end

    require("which-key").add({
      { "<leader>ss", "<cmd>GrugFar ripgrep<cr>", desc = "Search in project (ripgrep)" },
      { "<leader>sS", "<cmd>GrugFar astgrep<cr>", desc = "Search in project (ast-grep)" },
      { "<leader>sw", search_word_ripgrep,        desc = "Search word in project (ripgrep)" },
      { "<leader>sf", search_file_ripgrep,        desc = "Search in file (ripgrep)" },
      { "<leader>sF", search_file_astgrep,        desc = "Search in file (ast-grep)" },
    })
  end,
})

features.add({
  "Fancy diff view (uncommitted changes & file/branch history)",
  plugins = {
    {
      "sindrets/diffview.nvim",
      dependencies = {
        "nvim-tree/nvim-web-devicons",
      },
      init = function()
        -- fancy diff for deleted lines
        vim.opt.fillchars:append({ diff = "╱" })
      end,
      opts = {
        enhanced_diff_hl = true,
      },
    },
  },
  setup = function()
    require("which-key").add({
      {
        "<leader>gD",
        "<cmd>DiffviewOpen<cr>",
        desc = "Diff Unstaged",
      },
      {
        "<leader>gh",
        "<cmd>DiffviewFileHistory %<cr>",
        desc = "File History",
      },
      {
        "<leader>gH",
        "<cmd>DiffviewFileHistory<cr>",
        desc = "Branch History",
      },
    })
  end,
})

features.add({
  "Toggle word/line wrapping",
  setup = function()
    Snacks.toggle.option("wrap", { global = false }):map("<leader>Tl")
    Snacks.toggle.option("linebreak", { global = false }):map("<leader>Tw")
  end,
})

features.add({
  "Explore diagnostics/location/quickfix/lsp lists (trouble.nvim)",
  after = { "which-key" },
  plugins = {
    {
      "folke/trouble.nvim",
      opts = {},
      cmd = "Trouble",
    },
  },
  setup = function()
    require("which-key").add({
      {
        "<leader>xx",
        "<cmd>Trouble diagnostics toggle filter.buf=0 focus=true<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      {
        "<leader>xX",
        "<cmd>Trouble diagnostics toggle focus=true<cr>",
        desc = "Diagnostics (Trouble)",
      },
      {
        "<leader>xl",
        "<cmd>Trouble loclist toggle focus=true<cr>",
        desc = "Location List (Trouble)",
      },
      {
        "<leader>xs",
        function()
          ---@diagnostic disable-next-line: missing-fields
          require("trouble").toggle({
            mode = "symbols",
            focus = true,
            win = {
              size = {
                width = 120,
              },
            },
          })
        end,
        desc = "Symbols (Trouble)",
      },
      {
        "<leader>xL",
        function()
          ---@diagnostic disable-next-line: missing-fields
          require("trouble").toggle({
            mode = "lsp",
            focus = true,
            win = {
              position = "right",
              size = {
                width = 120,
              },
            },
          })
        end,
        desc = "LSP Definitions / references / ... (Trouble)",
      },
      {
        "<leader>xq",
        "<cmd>Trouble qflist toggle<cr>",
        desc = "Quickfix List (Trouble)",
      },
    })
  end,
})

features.add({
  "Undo-Tree",
  plugins = {
    {
      "jiaoshijie/undotree",
      dependencies = { "nvim-lua/plenary.nvim" },
      opts = {},
      keys = {
        {
          "<leader>uu",
          function()
            require("undotree").toggle()
          end,
          desc = "Undo Tree",
        },
      },
    },
  },
})

features.add({
  "Copy current relative file path with line number",
  after = { "which-key" },
  setup = function()
    local copy_relative_path_with_linum = function()
      local path = vim.fn.expand("%:.")
      local line = vim.fn.line(".")
      local text = string.format("%s:%d", path, line)
      vim.fn.setreg("+", text)
      vim.notify("Copied: " .. text)
    end

    require("which-key").add({
      {
        "<leader>ey",
        copy_relative_path_with_linum,
        desc = "Copy Relative Path with Line Number",
      },
    })
  end,
})

features.add({
  "Get/open link to repo for browser",
  plugins = {
    {
      "linrongbin16/gitlinker.nvim",
      cmd = "GitLink",
      opts = {},
      keys = {
        { "<leader>gy", "<cmd>GitLink<cr>",  mode = { "n", "v" }, desc = "Yank Git Link" },
        { "<leader>gY", "<cmd>GitLink!<cr>", mode = { "n", "v" }, desc = "Open Git Link" },
      },
    },
  },
})

features.add({
  "Fancy Markdown rendering despite being in a terminal",
  after = { "blink" },
  plugins = {
    {
      "MeanderingProgrammer/render-markdown.nvim",
      dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-tree/nvim-web-devicons",
        {
          "saghen/blink.cmp",
          opts = function(_, opts)
            table.insert(opts.sources.default, "markdown")
            opts.sources.providers.markdown = {
              name = "RenderMarkdown",
              module = "render-markdown.integ.blink",
              fallbacks = { "lsp" },
            }
          end,
        },
      },
      ---@module 'render-markdown'
      ---@type render.md.UserConfig
      opts = {
        file_types = { "markdown" },
        latex = {
          enabled = false,
        },
      },
    },
  },
})

features.add({
  "Support for Kitty terminal config",
  plugins = {
    {
      "fladson/vim-kitty",
      ft = "kitty",
    },
  },
})

features.add({
  "Jump Between Implementation and Test",
  after = { "which-key" },
  setup = function()
    local file_patterns = {
      elixir = {
        impl = "lib/*.ex",
        test = "test/*_test.exs",
      },
      go = {
        impl = "*.go",
        test = "*_test.go",
      },
      python = {
        impl = "*.py",
        test = "test_*.py",
      },
      ruby = {
        impl = "lib/*.rb",
        test = "test/*_test.rb",
      },
    }

    local function pattern_to_regex(pattern)
      local escaped = pattern:gsub("%.", "%."):gsub("%-", "%-")
      return "^" .. escaped:gsub("%*", "(.+)") .. "$"
    end

    local function pattern_to_format(pattern)
      return pattern:gsub("%*", "%%s")
    end

    local function create_file_with_dirs(path)
      local dir = vim.fn.fnamemodify(path, ":h")
      if dir ~= "." and vim.fn.isdirectory(dir) == 0 then
        vim.fn.mkdir(dir, "p")
      end
      vim.cmd("edit " .. path)
      vim.cmd("write")
    end

    local function jump_between_implementation_and_test()
      local buf_name = vim.fn.expand("%:.")
      local ft = vim.bo.filetype
      local patterns = file_patterns[ft]

      if not patterns then
        vim.notify("No test file pattern defined for filetype: " .. ft, vim.log.levels.WARN)
        return
      end

      local impl_regex = pattern_to_regex(patterns.impl)
      local test_regex = pattern_to_regex(patterns.test)

      local impl_match = string.match(buf_name, impl_regex)
      local test_match = string.match(buf_name, test_regex)

      local target_path
      local file_type
      if impl_match then
        target_path = string.format(pattern_to_format(patterns.test), impl_match)
        file_type = "test"
      elseif test_match then
        target_path = string.format(pattern_to_format(patterns.impl), test_match)
        file_type = "implementation"
      else
        vim.notify("Current file doesn't match any known pattern", vim.log.levels.WARN)
        return
      end

      if vim.fn.filereadable(target_path) == 1 then
        vim.cmd("edit " .. target_path)
      else
        vim.ui.select({ "Yes", "No" }, {
          prompt = string.format("Create %s file at %s?", file_type, target_path),
        }, function(choice)
          if choice == "Yes" then
            create_file_with_dirs(target_path)
          end
        end)
      end
    end

    require("which-key").add({
      {
        "<leader>et",
        jump_between_implementation_and_test,
        desc = "Jump Between Implementation and Test",
      },
    })
  end,
})

features.add({
  "Support for EBNF syntax highlighting",
  setup = function()
    vim.filetype.add({
      extension = {
        ebnf = "ebnf",
      },
    })
  end,
})

features.add({
  "Fidget notifications (used for LSP and CodeCompanion at the moment)",
  id = "fidget",
  plugins = {
    {
      "j-hui/fidget.nvim",
      opts = {},
    },
  },
  setup = function()
    local enabled = true

    Snacks.toggle
        .new({
          name = "Fidget Notifications (LSP, LLMs)",
          get = function()
            return enabled
          end,
          set = function(state)
            require("fidget").notification.suppress(not state)
            enabled = state
          end,
        })
        :map("<leader>Tf")
  end,
})

features.add({
  "Proper highliting for xrl and yrl files",
  setup = function()
    vim.filetype.add({
      extension = {
        xrl = 'erlang',
        yrl = 'erlang'
      }
    })
  end
})

features.add({
  "Delete file and close buffer",
  after = { "which-key" },
  setup = function()
    require("which-key").add({
      {
        "<leader>bd",
        function()
          local file = vim.fn.expand("%:p")
          if vim.fn.filereadable(file) == 1 then
            vim.ui.select({ "Yes", "No" }, {
              prompt = "Delete " .. file .. " and close buffer?",
            }, function(choice)
              if choice == "Yes" then
                vim.cmd("bd!")
                vim.fn.delete(file)
                vim.notify("Deleted: " .. file, vim.log.levels.INFO)
              end
            end)
          else
            vim.notify("File does not exist: " .. file, vim.log.levels.WARN)
          end
        end,
        desc = "Delete File and Close Buffer",
      }
    })
  end,
})

features.add({
  "Toggle whitespace characters visibility",
  after = { "snacks" },
  setup = function()
    vim.o.listchars = "tab:> ,trail:·,nbsp:+,lead:·"

    Snacks.toggle
        .new({
          name = "Whitespace Characters",
          get = function()
            return vim.o.list and true or false
          end,
          set = function(state)
            vim.o.list = state
          end,
        })
        :map("<leader>TS")
  end,
})

features.add({
  "Show diagnostics in virtual text",
  after = { "snacks" },
  setup = function()
    -- Enable virtual lines by default
    vim.diagnostic.config({
      virtual_lines = false,
    })

    -- Create toggle for diagnostics virtual text
    Snacks.toggle
        .new({
          name = "Diagnostics Virtual Text",
          get = function()
            return vim.diagnostic.config().virtual_lines and true or false
          end,
          set = function(state)
            vim.diagnostic.config({
              virtual_lines = state,
            })
          end,
        })
        :map("<leader>Td")
  end
})

features.add({
  "Jump between tabs by numner",
  after = { "which-key" },
  setup = function()
    require("which-key").add({
      { "<leader>t1", "<cmd>1tabnext<cr>", desc = "Tab 1" },
      { "g1",         "<cmd>1tabnext<cr>", desc = "Tab 1" },
      { "<leader>t2", "<cmd>2tabnext<cr>", desc = "Tab 2" },
      { "g2",         "<cmd>2tabnext<cr>", desc = "Tab 2" },
      { "<leader>t3", "<cmd>3tabnext<cr>", desc = "Tab 3" },
      { "g3",         "<cmd>3tabnext<cr>", desc = "Tab 3" },
      { "<leader>t4", "<cmd>4tabnext<cr>", desc = "Tab 4" },
      { "g4",         "<cmd>4tabnext<cr>", desc = "Tab 4" },
      { "<leader>t5", "<cmd>5tabnext<cr>", desc = "Tab 5" },
      { "g5",         "<cmd>5tabnext<cr>", desc = "Tab 5" },
      { "<leader>t6", "<cmd>6tabnext<cr>", desc = "Tab 6" },
      { "g6",         "<cmd>6tabnext<cr>", desc = "Tab 6" },
      { "<leader>t7", "<cmd>7tabnext<cr>", desc = "Tab 7" },
      { "g7",         "<cmd>7tabnext<cr>", desc = "Tab 7" },
    })
  end
})

-- TODO: togglable LSP symbols path in incline, statusline or popup like with " gb"
-- TODO: add Snack.image support
-- TODO: improve Copilot highlighting
-- TODO: fix autocompletion behavior in command mode
-- TODO: disable trailing spaces warnings in insert mode
-- TODO: zoom-in/out for windows (so I don't have to open a new tab)

features.load()
