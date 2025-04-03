local db = require("utils.db_data")
local opts = {}
local path = require("utils.db_path")
local tags = require("utils.db_tags")
local ui = require("utils.input")
local upd = require("utils.update")
local vt = require("utils.vt")
local M = {}

local function sign_in_all_commands(config_opts)
  local function restore_all()
    local filepath = vim.api.nvim_buf_get_name(0)
    local db_path = path.get_db_path(filepath)
    db.create_tbl(db_path)
    local line_count = vim.api.nvim_buf_line_count(0)
    local buf = vim.api.nvim_get_current_buf()
    local sidenotes = db.get_all_sidenotes(db_path)
    for _, sidenote in ipairs(sidenotes) do
      local line = sidenote.line
      local col = sidenote.col
      local id = sidenote.vt_id
      if line <= line_count and id > 0 then
        vt.remove_virtual_text_from_line(buf, line - 1)
        vt.add_virtual_line_with_connector(
          buf,
          line - 1,
          col,
          sidenote.text,
          config_opts.virtual_text.hl_group,
          id,
          config_opts.virtual_text.upper_connector,
          config_opts.virtual_text.lower_connector
        )
      end
    end
  end

  vim.api.nvim_create_user_command("SidenoteFoldAll", function()
    local filepath = vim.api.nvim_buf_get_name(0)
    local db_path = path.get_db_path(filepath)
    local buf = vim.api.nvim_get_current_buf()
    local sidenotes = db.get_all_sidenotes(db_path)
    for _, sidenote in ipairs(sidenotes) do
      local line = sidenote.line
      vt.remove_virtual_text_from_line(buf, line - 1)
    end
  end, {})

  --- TODO: be sure to reset all the virtual text when the line has been changed
  vim.api.nvim_create_user_command("SidenoteInsert", function()
    restore_all()
    local file_path = vim.api.nvim_buf_get_name(0)
    local db_path = path.get_db_path(file_path)
    local line = vim.api.nvim_win_get_cursor(0)[1]
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local buf = vim.api.nvim_get_current_buf()
    local id = vt.get_virtual_text_id_at_cursor()
    local vt_id = tags.generateTimestampTag()
    db.create_tbl(db_path)

    --- update and unopened Sidenote
    if upd.is_sidenote_exist(line) == true and id == 0 then
      local origin_text = db.get_by_line(db_path, line)[1].text
      ui.input_float({
        initial_text = origin_text,
        title = "Update Sidenote",
        callback = function(text)
          if text == "" then
            db.delete_by_line(db_path, line)
            return
          end
          db.update_by_line(db_path, line, { text = text, vt_id = vt_id, col = col })
          vt.remove_virtual_text_from_line(buf, line - 1)
          local hl_group = config_opts.virtual_text.hl_group
          vt.add_virtual_line_with_connector(
            buf,
            line - 1,
            col,
            text,
            hl_group,
            vt_id,
            config_opts.virtual_text.upper_connector,
            config_opts.virtual_text.lower_connector
          )
        end,
      })
      restore_all()
    -- case of opened Sidenote
    elseif upd.is_sidenote_exist(line) == true and id ~= 0 then
      local origin_text = db.get_by_line(db_path, line)[1].text
      ui.input_float({
        initial_text = origin_text,
        title = "Update Sidenote",
        callback = function(text)
          if text == "" then
            db.delete_by_id(db_path, id)
            return
          end
          vt.remove_virtual_text_from_line(buf, line - 1)
          db.update_by_id(db_path, id, { text = text, line = line, col = col })
          local hl_group = config_opts.virtual_text.hl_group
          vt.add_virtual_line_with_connector(
            buf,
            line - 1,
            col,
            text,
            hl_group,
            id,
            config_opts.virtual_text.upper_connector,
            config_opts.virtual_text.lower_connector
          )
        end,
      })
      restore_all()
    else
      ui.input_float({
        title = "Insert Sidenote",
        callback = function(text)
          db.add_entry(db_path, {
            filepath = file_path,
            line = line,
            col = col,
            text = text,
            vt_id = vt_id or 1,
          })
          vt.add_virtual_line_with_connector(
            buf,
            line - 1,
            col,
            text,
            config_opts.virtual_text.hl_group,
            vt_id,
            config_opts.virtual_text.upper_connector,
            config_opts.virtual_text.lower_connector
          )
        end,
      })
      restore_all()
    end
  end, {})

  vim.api.nvim_create_user_command("SidenoteRestoreAll", function()
    -- update.clean_invalid_sidenotes()
    restore_all()
  end, {})

  vim.api.nvim_create_user_command("SidenoteFoldAll", function()
    local filepath = vim.api.nvim_buf_get_name(0)
    local db_path = path.get_db_path(filepath)
    local buf = vim.api.nvim_get_current_buf()
    local sidenotes = db.get_all_sidenotes(db_path)
    for _, sidenote in ipairs(sidenotes) do
      local line = sidenote.line
      vt.remove_virtual_text_from_line(buf, line - 1)
    end
  end, {})

  vim.api.nvim_create_user_command("SidenoteTelescope", function()
    require("picker.telescope").show_sidenotes()
  end, {})
end

function M.setup_commands(in_opts)
  opts = in_opts
  sign_in_all_commands(opts)
end

function M.update_opts(in_opts)
  opts = in_opts
  sign_in_all_commands(opts)
end

return M
