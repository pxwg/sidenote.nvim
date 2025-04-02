local ui = require("utils.input")
local vt = require("utils.vt")

vim.api.nvim_create_user_command("SidenoteInsert", function()
  ui.input_float({
    title = "Insert Sidenote",
    callback = function(text)
      local buf = vim.api.nvim_get_current_buf()
      local line = vim.api.nvim_win_get_cursor(0)[1]
      local col = vim.api.nvim_win_get_cursor(0)[2]
      vt.add_virtual_line_with_connector(buf, line - 1, col, text, "Comment")
    end,
  })
end, {})
