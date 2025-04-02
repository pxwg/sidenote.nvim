local M = {}

M.default_opts = {
  input = {
    title = "Input",
    win_opts = {
      relative = "cursor",
      style = "minimal",
      border = "rounded",
      title_pos = "center",
    },
  },
  virtual_text = {
    hl_group = "Comment",
  },
}

return M
