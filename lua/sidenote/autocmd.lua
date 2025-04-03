local M = {}
local autocmd = vim.api.nvim_create_autocmd

---@param opts SideNoteOpts
local function subscribe_all_autocmds(opts)
  autocmd({ "VimResized", "WinResized" }, {
    callback = function()
      vim.cmd("SidenoteRestoreAll")
    end,
  })
end

---@param opts SideNoteOpts
function M.setup_autocmds(opts)
  subscribe_all_autocmds(opts)
end

---@param opts SideNoteOpts
function M.update_autocmds(opts)
  subscribe_all_autocmds(opts)
end

return M
