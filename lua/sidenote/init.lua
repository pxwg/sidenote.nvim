local M = {}
M.opts = {}
local default_opts = require("sidenote.default").default_opts

function M.setup(user_opts)
  M.opts = vim.tbl_deep_extend("force", default_opts, user_opts or {})
  require("utils.db_path").create_db_dir()
  require("sidenote.commands")
end

return M
