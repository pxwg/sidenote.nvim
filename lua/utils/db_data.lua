--- Manage the history of side notes with sqlite
local db_path = require("utils.db_path")
local sqlite = require("sqlite.db") --- for constructing sql databases
local tbl = require("sqlite.tbl") --- for constructing sql tables

local M = {}

--- @class SideNote
--- @field public filepath string current file path of the side note
--- @field public vt_id integer
--- @field public text string the text content of the side note
--- @field public col integer column position
--- @field public line integer line position
--- @field public hl_group string? highlight group

--- Table definition for side notes
local sidenotes = {
  id = true,
  vt_id = { "integer", required = true },
  hl_group = "text",
  text = { "text", required = true },
  col = { "integer", required = true }, -- column number
  line = { "integer", required = true }, -- line number
  filepath = { "text", required = true },
  ensure = true,
}

--- Creates a connection to the database
--- @param path string the path to the database
--- @return table database connection
local function connect_to_db(path)
  return sqlite({
    uri = path,
    opts = {},
  })
end

--- Create a table in the database
--- @param path string|nil the path to the database
function M.create_tbl(path)
  if not path then
    return
  end
  if not db_path.file_exists(path) then
    local file = io.open(path, "w")
    if file then
      file:close()
    else
      vim.notify("sidenote.nvim: Failed to create database file", vim.log.levels.ERROR)
      return
    end
  end

  local db = connect_to_db(path)
  db:with_open(path, function()
    db:create("sidenotes", sidenotes)
  end)
end

--- Function to add a new entry
--- @param path string
--- @param entry SideNote
--- @return SideNote
function M.add_entry(path, entry)
  local db = connect_to_db(path)
  local result
  db:with_open(path, function()
    result = db:insert("sidenotes", entry)
  end)
  return result
end

--- Function to get entries by column
--- @param path string
--- @param col number
--- @return SideNote[]
function M.get_by_col(path, col)
  local db = connect_to_db(path)
  local result
  db:with_open(path, function()
    result = db:select("sidenotes", { where = { col = col } })
  end)
  return result
end

--- Function to get entries by id
--- @param path string
--- @param id number
--- @return SideNote[]
function M.get_by_id(path, id)
  local db = connect_to_db(path)
  local result
  db:with_open(path, function()
    result = db:select("sidenotes", { where = { vt_id = id } })
  end)
  return result
end

--- Function to get entries by line
--- @param path string
--- @param line number
--- @return SideNote[]
function M.get_by_line(path, line)
  local db = connect_to_db(path)
  local result
  db:with_open(path, function()
    result = db:select("sidenotes", { where = { line = line } })
  end)
  return result
end

--- Function to update an entry by column
--- @param path string
--- @param id number
--- @param updates table fields to update
function M.update_by_id(path, id, updates)
  local db = connect_to_db(path)
  db:with_open(path, function()
    db:update("sidenotes", {
      where = { vt_id = id },
      set = updates,
    })
  end)
end

--- Function to update an entry by column
--- @param path string
--- @param line number
--- @param updates table fields to update
function M.update_by_line(path, line, updates)
  local db = connect_to_db(path)
  db:with_open(path, function()
    db:update("sidenotes", {
      where = { line = line },
      set = updates,
    })
  end)
end

--- Function to delete an entry by column
--- @param path string
--- @param id number
--- @return boolean success
function M.delete_by_id(path, id)
  local db = connect_to_db(path)
  local result
  db:with_open(path, function()
    result = db:delete("sidenotes", { where = { vt_id = id } })
  end)
  return result
end

--- Function to delete an entry by column
--- @param path string
--- @param line number
--- @return boolean success
function M.delete_by_line(path, line)
  local db = connect_to_db(path)
  local result
  db:with_open(path, function()
    result = db:delete("sidenotes", { where = { line = line } })
  end)
  return result
end

--- Function to get all sidenotes from the table
--- @param path string path to the database file
--- @return  SideNote[] all sidenotes in the database
function M.get_all_sidenotes(path)
  local db = connect_to_db(path)
  local result
  db:with_open(path, function()
    result = db:select("sidenotes", {})
  end)
  return result or {}
end

return M
