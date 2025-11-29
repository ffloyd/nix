local M = {}

function M.getFgHexColorFromHighlight(hlName)
  local hl = vim.api.nvim_get_hl(0, { name = hlName, link = false })

  if not hl.fg then
    return nil
  end

  return string.format("#%06x", hl.fg)
end

return M
