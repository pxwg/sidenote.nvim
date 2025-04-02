--- the update module
local db = require("utils.db_data")
local path = require("utils.db_path")
local M = {}

function M.is_sidenote_exist(line)
  print(line)
  local file_path = vim.api.nvim_buf_get_name(0)
  local db_path = path.get_db_path(file_path)
  local sidenotes = db.get_by_line(db_path, line)
  print(vim.inspect(sidenotes))
  return #sidenotes > 0
end

return M
