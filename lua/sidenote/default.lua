local M = {}

--- @class SideNoteWinOpts
--- @field relative string?
--- @field style string?
--- @field border string?
--- @field title_pos string?

--- @class SideNoteInputOpts
--- @field title string?
--- @field win_opts SideNoteWinOpts?

--- @class SideNoteVirtualTextOpts
--- @field hl_group string?
--- @field upper_connector string?
--- @field lower_connector string?
--- @field prefix string?

--- @class SideNoteOpts
--- @field input SideNoteInputOpts?
--- @field virtual_text SideNoteVirtualTextOpts?

--- @type SideNoteOpts
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
    upper_connector = "┌─",
    lower_connector = "└─",
    prefix = "◆",
  },
}

return M
