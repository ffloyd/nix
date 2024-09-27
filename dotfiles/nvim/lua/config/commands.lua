local function rename_current_file()
  local current_file = vim.fn.expand("%")

  -- Save the current file
  vim.cmd("write")

  vim.ui.input({
    prompt = "New file name: ",
    default = current_file,
    completion = "file",
  }, function(new_file)
    if new_file and new_file ~= "" and new_file ~= current_file then
      local success, err = vim.uv.fs_rename(current_file, new_file)

      if not success then
        vim.notify("Error renaming file: " .. err, vim.log.levels.ERROR)
        return
      end

      vim.cmd("edit " .. vim.fn.fnameescape(new_file))
      vim.notify("File renamed to: " .. new_file, vim.log.levels.INFO)
    end
  end)
end

-- Set up a command to call this function
vim.api.nvim_create_user_command("RenameFile", rename_current_file, { desc = "Rename the current file" })
