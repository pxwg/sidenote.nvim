--- the update module
local db = require("utils.db_data")
local path = require("utils.db_path")
local M = {}

function M.is_sidenote_exist(line)
  local file_path = vim.api.nvim_buf_get_name(0)
  local db_path = path.get_db_path(file_path)
  local sidenotes = db.get_by_line(db_path, line) --- deal with line number even if the sidenotes are folded
  return #sidenotes > 0
end

function M.clean_invalid_sidenotes(filepath)
  filepath = filepath or vim.api.nvim_buf_get_name(0)
  local file = io.open(filepath, "r")
  if not file then
    return
  end

  local line_count = 0
  for _ in file:lines() do
    line_count = line_count + 1
  end
  file:close()

  local db_path = path.get_db_path(filepath)
  if not path.file_exists(db_path) then
    return
  end

  local all_sidenotes = db.get_all_sidenotes(db_path)

  for _, sidenote in ipairs(all_sidenotes) do
    if sidenote.filepath == filepath and sidenote.line > line_count then
      db.delete_by_id(db_path, sidenote.vt_id)
    end
  end
end

return M
