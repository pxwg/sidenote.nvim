local M = {}

function M.setup(user_opts)
  require("utils.db_path").create_db_dir()
  require("sidenote.commands")
end

return M
