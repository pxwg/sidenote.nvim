--- UI module for creating and managing side notes
local M = {}
local config_opts = require("sidenote").opts

--- Creates a floating window at cursor position for user input
--- @class SideNoteFloatOpt table Optional parameters:
--- @field public width number?: Width of the floating window (default: 40)
--- @field public height number?: Height of the floating window (default: 6)
--- @field public title string: Title of the window (default: "Input")
--- @field public callback function: Called with the input text when closed
--- @field public initial_text string?: Initial text to display in the window

--- Creates a floating window at cursor position for user input
--- @param opts SideNoteFloatOpt
--- @return number: Buffer number of the created buffer
function M.input_float(opts)
  opts = opts or {}
  local width = opts.width or 40
  local height = opts.height or 6
  local title = opts.title or "Input"
  local initial_text = opts.initial_text or ""

  -- Get current cursor position
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local current_line = cursor_pos[1] - 1
  local current_col = cursor_pos[2]

  -- Create buffer for the floating window
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
  vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
  vim.api.nvim_set_option_value("filetype", "markdown", { buf = buf })

  local win_height = vim.api.nvim_win_get_height(0)
  local win_width = vim.api.nvim_win_get_width(0)
  local row = current_line
  local col = current_col

  -- Adjust position if window would go off screen
  if row + height + 2 > win_height then
    row = win_height - height - 2
  end
  if col + width + 2 > win_width then
    col = win_width - width - 2
  end

  -- Window options
  local win_opts = {
    row = row,
    col = col,
    width = width,
    height = height,
  }
  win_opts = vim.tbl_extend("force", config_opts.input.win_opts, win_opts)

  -- Split initial text by newlines and insert into buffer
  if initial_text and initial_text ~= "" then
    local lines = {}
    for line in (initial_text .. "\n"):gmatch("(.-)\n") do
      table.insert(lines, line)
    end
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  end

  local win = vim.api.nvim_open_win(buf, true, win_opts)

  vim.api.nvim_set_option_value("wrap", true, {})
  vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
  vim.cmd("startinsert")
  local callback_fn = opts.callback

  -- Position cursor at end of text if there's initial text
  if initial_text and initial_text ~= "" then
    vim.schedule(function()
      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      local last_line_idx = #lines
      local last_line = lines[last_line_idx] or ""
      local last_col = vim.fn.strwidth(last_line)
      vim.api.nvim_win_set_cursor(win, { last_line_idx, last_col })
      vim.cmd("startinsert!") -- Ensure cursor is at end of text
    end)
  end

  vim.api.nvim_create_autocmd({ "BufLeave" }, {
    buffer = buf,
    once = true,
    callback = function()
      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      while #lines > 0 and lines[#lines] == "" do
        table.remove(lines, #lines)
      end
      local text = table.concat(lines, "\n")
      vim.schedule(function()
        if vim.api.nvim_win_is_valid(win) then
          vim.api.nvim_win_close(win, true)
        end

        if callback_fn then
          callback_fn(text)
        end
      end)
    end,
  })
  return buf
end

return M
