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
    local newline_found = false

    -- Keep adding characters until we exceed max width
    while chunk_end <= text_length and current_width < max_display_width do
      if string.sub(text, chunk_end, chunk_end) == "\n" then
        newline_found = true
        break
      end

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
      if char == " " and current_width >= max_display_width - char_width then
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

    if newline_found then
      -- Add text up to the newline
      table.insert(lines, string.sub(text, current_pos, chunk_end - 1))
      current_pos = chunk_end + 1 -- Skip the newline character
    else
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
--- @param text string: The text to display in the virtual line
--- @param hl_group string: The highlight group to use for the virtual line
function M.add_virtual_line_with_connector(bufnr, line_nr, col_nr, text, hl_group)
  bufnr = bufnr or 0
  --- TODO: Custumizable default hl_group
  hl_group = hl_group or "Comment"

  -- Get window width for line wrapping calculation
  local win_width = vim.api.nvim_win_get_width(0)
  local max_display_width = win_width - col_nr - 10

  local lines = M.wrap_text_to_fit_width(text, max_display_width)
  local virt_lines = {}

  -- Add the text lines with appropriate connectors
  for i, line in ipairs(lines) do
    local connector
    if i == 1 then
      connector = #lines > 1 and "├─ " or "└─ "
    elseif i == #lines then
      connector = "└─ "
    else
      connector = "│  "
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

-- test
-- local text =
--   [[Hello世界！今󠄂天是2023-π/2≈5.15的奇妙日期🌍！在α坐标系中，用户@张三_Dev需要将€50转换为¥或$，同时计算∑(n²)从n=1到∞。Ω公司发布的📱App 2.0支持≤5Gbps传输，但需注意⚠️：温度阈值应保持25°C±3%！代码段if (x != y) { cout << "错误❌"; } 包含中文注释//这里要处理ASCII码32~126。数学公式∮E·da = Q/ε₀展示∇·E=ρ/ε₀的微分形式。购物清单📋：🍎×6（$4.99）、📘×3（¥59.8/本），总价≈$4.99×6 + 59.8×3 = $29.94 + ￥179.4。音乐播放列表🎵：《最伟大的作品》- 周杰倫（Jay Chou） feat. 郎朗，码率320kbps@48kHz。地址示例：北京市海淀区#36号院©2023，地图坐标39°54'27"N 116°23'17"E。特殊符号测试：★☆☯☢☣♬♔♛⚡🔥💻✅🔍🛑🚫⚖️🔄📶📡🔑🔓💡❗❓‼️⁉️➡️⬅️↙️↗️🔀🔁🔂⏩⏪⏫⏬🎦🔅🔆🕒🕘🕧🔢🔣🔤🅰️🆎🆑🆘🆚]]
--
-- --
-- M.add_virtual_line_with_connector(0, 153, 0, text, "Comment")

return M
