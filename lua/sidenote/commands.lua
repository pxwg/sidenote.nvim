local db = require("utils.db_data")
local path = require("utils.db_path")
local tags = require("utils.db_tags")
local ui = require("utils.input")
local upd = require("utils.update")
local update = require("utils.update")
local vt = require("utils.vt")

local function restore_all()
  local filepath = vim.api.nvim_buf_get_name(0)
  local db_path = path.get_db_path(filepath)
  db.create_tbl(db_path)
  local line_count = vim.api.nvim_buf_line_count(0)
  local buf = vim.api.nvim_get_current_buf()
  local sidenotes = db.get_all_sidenotes(db_path)
  for _, sidenote in ipairs(sidenotes) do
    local line = sidenote.line
    local col = sidenote.col
    local id = sidenote.vt_id
    if line < line_count and id > 0 then
      vt.remove_virtual_text_from_line(buf, line - 1)
      vt.add_virtual_line_with_connector(buf, line - 1, col, sidenote.text, "Comment", id)
    end
  end
end

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

--- TODO: be sure to reset all the virtual text when the line has been changed
vim.api.nvim_create_user_command("SidenoteInsert", function()
  -- restore_all()
  local file_path = vim.api.nvim_buf_get_name(0)
  local db_path = path.get_db_path(file_path)
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local buf = vim.api.nvim_get_current_buf()
  local id = vt.get_virtual_text_id_at_cursor()
  local vt_id = tags.generateTimestampTag()
  db.create_tbl(db_path)

  --- update
  if upd.is_sidenote_exist(line) == true then
    local origin_text = db.get_by_line(db_path, line)[1].text
    ui.input_float({
      initial_text = origin_text,
      title = "Update Sidenote",
      callback = function(text)
        if text == "" then
          db.delete_by_line(db_path, line)
          return
        end
        db.update_by_line(db_path, line, { text = text, vt_id = vt_id })
        vt.remove_virtual_text_from_line(buf, line - 1)
        if id > 0 then
          vt.add_virtual_line_with_connector(buf, line - 1, col, text, "Comment", vt_id)
        end
      end,
    })
    restore_all()
  else
    ui.input_float({
      title = "Insert Sidenote",
      callback = function(text)
        db.add_entry(db_path, {
          filepath = file_path,
          line = line,
          col = col,
          text = text,
          vt_id = vt_id or 1,
        })
        vt.add_virtual_line_with_connector(buf, line - 1, col, text, "Comment", vt_id)
      end,
    })
    restore_all()
  end
end, {})

vim.api.nvim_create_user_command("SidenoteRestoreAll", function()
  -- update.clean_invalid_sidenotes()
  restore_all()
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

vim.api.nvim_create_user_command("SidenoteTelescope", function()
  require("picker.telescope").show_sidenotes()
end, {})
