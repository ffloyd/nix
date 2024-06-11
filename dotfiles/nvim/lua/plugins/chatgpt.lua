return {
  "jackMort/ChatGPT.nvim",
  event="VeryLazy",
  dependencies = {
    "MunifTanjim/nui.nvim",
    "nvim-lua/plenary.nvim",
    "folke/trouble.nvim",
    "nvim-telescope/telescope.nvim"
  },
  opts = {
    api_key_cmd = "pass openai/api_key"
  }
}
-- TODO: use gpt-4o by default
-- TODO: integrate with whichkey
