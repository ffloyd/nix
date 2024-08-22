-- 
-- Manage and run various tasks: from make to mix
--
return {
  {
    'stevearc/overseer.nvim',
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "stevearc/dressing.nvim",
      "rcarriga/nvim-notify"
    },
    config = function()
      local overseer = require("overseer")

      overseer.setup({})

      overseer.register_template({
        name = "ExUnit: test file",
        desc = "Runs 'mix test' for currently open file.",
        condition = {
          filetype = { "elixir" },
        },
        builder = function()
          local file = vim.fn.expand("%")
          return {
            cmd = { "mix" },
            args = { "test", file },
            components = {
              { "on_output_quickfix", open_on_exit = "failure", set_diagnostics = true },
              { "on_result_diagnostics", remove_on_restart = true },
              "default"
            },
          }
        end
      })
    end
  }
}