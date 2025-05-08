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

features.add({
  "Use a colorscheme that inspired by the Kanagawa wave",
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
  setup = function()
    require("which-key").add({
      { "<leader>a", group = "Apps/AI" },
      { "<leader>b", group = "Buffer" },
      { "<leader>e", group = "Editor Helpers" },
      { "<leader>g", group = "Git/VCS" },
      { "<leader>f", group = "Finders" },
      { "<leader>s", group = "Search/Replace" },
      { "<leader>T", group = "Tabs" },
      { "<leader>t", group = "Toggle" },
      { "<leader>u", group = "Utils" },
      { "<leader>x", group = "eXplore" },
      { "<leader>?", group = "Help" },
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
  "Fetch default configurations for LSP servers (with respect to blink.cmp)",
  plugins = {
    {
      "neovim/nvim-lspconfig",
      dependencies = { "saghen/blink.cmp" },
      config = function()
        local lspconfig = require("lspconfig")
        local capabilities = require("blink-cmp").get_lsp_capabilities()

        lspconfig.dockerls.setup({ capabilities = capabilities })
        lspconfig.lua_ls.setup({ capabilities = capabilities })
        lspconfig.gopls.setup({ capabilities = capabilities })
        lspconfig.lexical.setup({
          cmd = { "lexical" },
          capabilities = capabilities,
        })
        -- lspconfig.elixirls.setup({ capabilities = capabilities, cmd = { "elixir-ls" } })
        lspconfig.nixd.setup({ capabilities = capabilities })
        lspconfig.terraformls.setup({ capabilities = capabilities })
        lspconfig.ts_ls.setup({ capabilities = capabilities })
        lspconfig.rust_analyzer.setup({ capabilities = capabilities })
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
  "Autocompletion with Blink",
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
  "Enable Snacks.nvim",
  plugins = {
    {
      "folke/snacks.nvim",
      priority = 1000,
      lazy = false,
      opts = {},
    },
  },
})
---@module "snacks"

features.add({
  "Fancy dashboard with Snacks",
  plugins = {
    {
      "folke/snacks.nvim",
      opts = function(_, opts)
        opts.dashboard = {
          example = "advanced",
        }
      end,
    },
  },
})

features.add({
  "Better UI elements from Snacks",
  plugins = {
    {
      "folke/snacks.nvim",
      opts = function(_, opts)
        opts.statuscolumn = {
          enabled = true,
          folds = {
            open = true,
            git_hl = true,
          },
        }
        opts.input = { enabled = true }
        opts.notifier = { enabled = true }
        opts.picker = { enabled = true, ui_select = true }
      end,
    },
  },
})

require("features").add({
  "Enable fancy fuzzy finders",
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
  "Discover top-level keybindings",
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
  "Search lines by `C-SPC C-SPC` and files by `SPC SPC`",
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
  setup = function()
    Snacks.toggle.option("spell"):map("<leader>ts")
    Snacks.toggle.indent():map("<leader>ti")
    Snacks.toggle.line_number():map("<leader>tn")
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
  "Rename a file with Snacks",
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

require("ai")

require("features").add({
  "Show file name in a buffer corner",
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
        "<leader>Tn",
        "<cmd>tabnext<cr>",
        desc = "Next Tab",
      },
      {
        "<leader>Tp",
        "<cmd>tabprevious<cr>",
        desc = "Previous Tab",
      },
      {
        "<leader>Tl",
        "<cmd>+tabmove<cr>",
        desc = "Move Tab Right",
      },
      {
        "<leader>Th",
        "<cmd>-tabmove<cr>",
        desc = "Move Tab Left",
      },
      {
        "<leader>Tt",
        "<cmd>$tabnew<cr>",
        desc = "New Tab",
      },
      {
        "<leader>Tk",
        "<cmd>tabclose<cr>",
        desc = "Close Tab",
      },
      {
        "<leader>Tr",
        function()
          local newname = vim.fn.input("Rename tab to: ")
          require("tabby").tab_rename(newname)
        end,
        desc = "Rename Tab",
      },
      {
        "<leader>To",
        "<cmd>tabonly<cr>",
        desc = "Close Other Tabs",
      },
    })
  end,
})

features.add({
  "Toggle terminal",
  plugins = {
    {
      "folke/snacks.nvim",
      opts = function(_, opts)
        ---@type snacks.terminal.Config
        opts.terminal = {}
      end,
    },
  },
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

features.add({
  "LSP code actions & rename",
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
        :map("<leader>tg")
  end,
})

features.add({
  "Git hunks/diffs in-buffer navigation and control",
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
        :map("<leader>tb")

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
      ---@type GrugFarOptions
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
    Snacks.toggle.option("wrap", { global = false }):map("<leader>tl")
    Snacks.toggle.option("linebreak", { global = false }):map("<leader>tw")
  end,
})

features.add({
  "Explore diagnostics/location/quickfix/lsp lists (trouble.nvim)",
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
  "Control LSP status",
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
  "Model Communication Protocol (MCP)",
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
  "Fancy Markdown rendering despite being in a terminal",
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
  "File Explorer (snacks.nvim)",
  plugins = {
    {
      "folke/snacks.nvim",
      opts = function(_, opts)
        ---@type snacks.explorer.Config
        opts.explorer = {
          replace_netrw = true,
        }

        opts.picker = opts.picker or {}
        opts.picker.sources = opts.picker.sources or {}
        opts.picker.sources.explorer = {
          layout = { preset = "default", preview = false },
          auto_close = true,
          jump = { close = true },
        }
      end,
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
  "Jump Between Implementation and Test",
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
  "List recent notifications",
  plugins = {
    {
      "folke/snacks.nvim",
      opts = function(_, opts)
        opts.notifier = { enabled = true }
      end,
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

features.add({
  "Formatters and Linters",
  plugins = {
    {
      "nvimtools/none-ls.nvim",
      opts = function(_, opts)
        local null_ls = require("null-ls")

        opts.sources = {
          -- Formatters
          null_ls.builtins.formatting.nix_flake_fmt,
          null_ls.builtins.formatting.mix,
          null_ls.builtins.formatting.stylua,
          null_ls.builtins.formatting.terraform_fmt,
          -- Linters
          null_ls.builtins.diagnostics.credo,
          null_ls.builtins.diagnostics.editorconfig_checker,
          null_ls.builtins.diagnostics.hadolint,
          null_ls.builtins.diagnostics.statix,
          null_ls.builtins.diagnostics.terraform_validate,
          null_ls.builtins.diagnostics.todo_comments,
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
        :map("<leader>tf")
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

-- TODO: togglable LSP symbols path in incline, statusline or popup like with " gb"
-- TODO: jump between tabs by g1, g2, g3, etc
-- TODO: add Snack.image support
-- TODO: switch to CodeCompanion and adopt mcp - ____IN PROGRESS____
-- TODO: improve Copilot highlighting
-- TODO: fix autocompletion behavior in command mode
-- TODO: disable trailing spaces warnings in insert mode
-- TODO: zoom-in/out for windows (so I don't have to open a new tab)

features.load()
