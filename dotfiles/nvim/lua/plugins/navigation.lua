--
-- Navigation between many types of things
--
return {
  { "nvim-telescope/telescope-fzf-native.nvim", build = 'make' },
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "nvim-telescope/telescope-fzf-native.nvim"
    },
    config = function()
      local telescope = require("telescope")

      telescope.load_extension("fzf")
    end
  }
}
