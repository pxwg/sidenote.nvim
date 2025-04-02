local M = {}
local dir_path = vim.fn.expand("$HOME") .. "/.local/state/nvim/sidenotes"

function M.create_db_dir()
  if not M.file_exists(dir_path) then
    vim.fn.mkdir(dir_path, "p")
  end
end

function M.get_db_path(file_path)
  local buf = vim.api.nvim_get_current_buf()
  file_path = file_path or vim.api.nvim_buf_get_name(buf)
  file_path = file_path:gsub("^%s+", ""):gsub("%s+$", ""):gsub("%.", ""):gsub("/", "_")
  local path = vim.fn.expand("$HOME") .. "/.local/state/nvim/sidenotes/" .. file_path .. ".db"
  return path
end

--- @param file_path string
function M.file_exists(file_path)
  local stat = vim.loop.fs_stat(file_path)
  return stat ~= nil
end

function M.check_db_file_exists()
  local db_path = M.get_db_path()
  return M.file_exists(db_path)
end

return M
