local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values
local action_state = require("telescope.actions.state")
local actions = require("telescope.actions")
local db_data = require("utils.db_data")
local displayer = require("telescope.pickers.entry_display").create({
  separator = " ",
  items = {
    { width = 4 },
    { remaining = true },
  },
})
local path = require("utils.db_path")
local previewers = require("telescope.previewers")

local M = {}

--- Show all sidenotes in a telescope picker
--- @param opts table? telescope options
function M.show_sidenotes(opts)
  opts = opts or {}

  -- Get the database path for the current file
  local file_path = vim.api.nvim_buf_get_name(0)
  local db_path = path.get_db_path(file_path)

  local sidenotes = db_data.get_all_sidenotes(db_path)

  local finder = finders.new_table({
    results = sidenotes,
    entry_maker = function(entry)
      local first_line = entry.text:match("^[^\n]*") or ""
      if first_line ~= entry.text then
        first_line = first_line .. "..."
      end
      first_line = first_line:gsub("%s+", " ")

      local make_display = function()
        return displayer({
          { entry.line .. ":", "TelescopeResultsLineNr" },
          { first_line, "TelescopeResultsIdentifier" },
        })
      end

      local ordinal = string.format("%s:%d:%s", entry.filepath, entry.line, first_line)

      return {
        value = entry,
        display = make_display,
        ordinal = ordinal,
        path = entry.filepath,
        lnum = entry.line,
        col = entry.col,
      }
    end,
  })

  pickers
    .new(opts, {
      prompt_title = "Sidenotes",
      finder = finder,
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          local selection = action_state.get_selected_entry()
          actions.close(prompt_bufnr)

          vim.api.nvim_win_set_cursor(0, { selection.lnum, selection.col })
        end)
        return true
      end,
    })
    :find()
end

return M
