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
