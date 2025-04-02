--- the update module
local db = require("utils.db_data")
local path = require("utils.db_path")
local vt = require("utils.vt")
local M = {}

function M.is_sidenote_exist(line)
  local file_path = vim.api.nvim_buf_get_name(0)
  local db_path = path.get_db_path(file_path)
  local id = vt.get_virtual_text_id_at_cursor()
  local sidenotes = db.get_by_id(db_path, id)
  return #sidenotes > 0
end

return M
