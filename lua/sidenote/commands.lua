local db = require("utils.db_data")
local path = require("utils.db_path")
local ui = require("utils.input")
local upd = require("utils.update")
local vt = require("utils.vt")

--- TODO: add update instead of cover the previous one
vim.api.nvim_create_user_command("SidenoteInsert", function()
  local file_path = vim.api.nvim_buf_get_name(0)
  local db_path = path.get_db_path(file_path)
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local buf = vim.api.nvim_get_current_buf()
  db.create_tbl(db_path)

  if upd.is_sidenote_exist(line) == true then
    vt.remove_virtual_text_from_line(buf, line - 1)
    local origin_text = db.get_by_line(db_path, line)[1].text
    ui.input_float({
      initial_text = origin_text,
      title = "Update Sidenote",
      callback = function(text)
        if text == "" then
          db.delete_by_line(db_path, line)
          return
        end
        db.update_by_line(db_path, line, { text = text })
        vt.add_virtual_line_with_connector(buf, line - 1, col, text, "Comment")
      end,
    })
  else
    ui.input_float({
      title = "Insert Sidenote",
      callback = function(text)
        db.add_entry(db_path, {
          filepath = file_path,
          line = vim.api.nvim_win_get_cursor(0)[1],
          col = vim.api.nvim_win_get_cursor(0)[2],
          text = text,
        })
        vt.add_virtual_line_with_connector(buf, line - 1, col, text, "Comment")
      end,
    })
  end
end, {})

vim.api.nvim_create_user_command("SidenoteRestoreAll", function()
  local filepath = vim.api.nvim_buf_get_name(0)
  local db_path = path.get_db_path(filepath)
  local buf = vim.api.nvim_get_current_buf()
  local sidenotes = db.get_all_sidenotes(db_path)
  for _, sidenote in ipairs(sidenotes) do
    local line = sidenote.line
    local col = sidenote.col
    vt.remove_virtual_text_from_line(buf, line - 1)
    vt.add_virtual_line_with_connector(buf, line - 1, col, sidenote.text, "Comment")
  end
end, {})

vim.api.nvim_create_user_command("SidenoteFoldAll", function()
  local filepath = vim.api.nvim_buf_get_name(0)
  local db_path = path.get_db_path(filepath)
  local buf = vim.api.nvim_get_current_buf()
  local sidenotes = db.get_all_sidenotes(db_path)
  for _, sidenote in ipairs(sidenotes) do
    local line = sidenote.line
    vt.remove_virtual_text_from_line(buf, line - 1)
  end
end, {})
