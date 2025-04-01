--- Manage virt_text in neovim
local M = {}

--- @class VirtualText
--- @field public hl_group string highlight group
--- @field public text string text to display
--- @field public col integer column number
--- @field public line integer line number
--- @field public max_display_width integer current window width

--- @param str string
function M.get_display_width(str)
  return vim.fn.strdisplaywidth(str)
end

--- HACK: Function that wraps text to fit within a specified width
--- This is a hacky implementation that doesn't handle all edge cases
---
--- @param text string: The text to wrap
--- @param max_display_width integer: The maximum width to wrap the text to (e.g. window width)
function M.wrap_text_to_fit_width(text, max_display_width)
  local lines = {}
  local current_pos = 1
  local text_length = #text

  while current_pos <= text_length do
    local chunk_end = current_pos
    local current_width = 0
    local last_space_pos = nil
    local last_valid_end = current_pos

    -- Keep adding characters until we exceed max width
    while chunk_end <= text_length and current_width < max_display_width do
      -- Get next UTF-8 character
      local byte = string.byte(text, chunk_end)
      local char_len = 1
      if byte >= 0xC0 and byte <= 0xDF then
        char_len = 2
      elseif byte >= 0xE0 and byte <= 0xEF then
        char_len = 3
      elseif byte >= 0xF0 and byte <= 0xF7 then
        char_len = 4
      end

      local char = string.sub(text, chunk_end, chunk_end + char_len - 1)
      local char_width = M.get_display_width(char)

      -- Track the last space for word breaking
      if char == " " then
        last_space_pos = chunk_end
      end

      -- Check if adding this character would exceed the limit
      if current_width + char_width > max_display_width then
        break
      end

      current_width = current_width + char_width
      chunk_end = chunk_end + char_len
      last_valid_end = chunk_end - 1
    end

    -- If we have a space to break at and it makes sense to use it
    if last_space_pos and last_space_pos > current_pos and (last_valid_end - last_space_pos) < 15 then
      chunk_end = last_space_pos
    else
      chunk_end = last_valid_end
    end

    table.insert(lines, string.sub(text, current_pos, chunk_end))
    current_pos = chunk_end + 1

    -- Skip leading space on next line
    if current_pos <= text_length and string.sub(text, current_pos, current_pos) == " " then
      current_pos = current_pos + 1
    end
  end

  return lines
end

--- Add a virtual line with a connector to the specified buffer
--- *example*:
--- input: "Hello, world!"
--- display:
--- "│               "
--- "└─ Hello, world!"
--- @param bufnr number: The buffer number to add the virtual line to
--- @param line_nr number: The line number to add the virtual line after
--- @param col_nr number: The column number to add the virtual line at
function M.add_virtual_line_with_connector(bufnr, line_nr, col_nr, text, hl_group)
  bufnr = bufnr or 0
  --- TODO: Custumizable default hl_group
  hl_group = hl_group or "Comment"

  -- Get window width for line wrapping calculation
  local win_width = vim.api.nvim_win_get_width(0)
  local max_display_width = win_width - col_nr - 8

  local lines = M.wrap_text_to_fit_width(text, max_display_width)

  local virt_lines = {}

  --- TODO: Custumizable default hl_group
  table.insert(virt_lines, { { "│", "LineNr" } })

  -- Add the text lines with appropriate connectors
  for i, line in ipairs(lines) do
    local connector
    if i == 1 then
      connector = "├─ " -- First line gets a tee connector
    elseif i == #lines then
      connector = "└─ " -- Last line gets a corner connector
    else
      connector = "│  " -- Middle lines get a vertical line with space
    end

    table.insert(virt_lines, { { connector, "LineNr" }, { line, hl_group } })
  end

  vim.api.nvim_buf_set_extmark(
    bufnr,
    vim.g.namespace_id or vim.api.nvim_create_namespace("statusline_virt"),
    line_nr,
    col_nr,
    {
      virt_lines = virt_lines,
      virt_lines_above = false,
      hl_mode = "combine",
    }
  )
end

--- Remove virtual text to a line in a buffer
--- @param bufnr number: The buffer number to remove the virtual text from
--- @param line_nr number: The line number to remove the virtual text from
function M.remove_virtual_text_from_line(bufnr, line_nr)
  bufnr = bufnr or 0
  local namespace = vim.g.namespace_id or vim.api.nvim_create_namespace("statusline_virt")
  vim.api.nvim_buf_clear_namespace(bufnr, namespace, line_nr, line_nr + 1)
end

return M
