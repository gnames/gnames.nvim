local util = require "gnames.util"
local config = require "gnames.config"
local api = vim.api

local M = {}

local panel_var = "GNamesForBuf"
local panel_ns = api.nvim_create_namespace(config.panel_ns)

---
---Checks if a buffer is opened in at least one window (not hidden).
---
---@param bufnr number
---@return boolean
local function is_buf_visible(bufnr)
  local windows = vim.fn.win_findbuf(bufnr)

  return #windows > 0
end

---
---Closes all windows for a particular buffer
---
---@param bufnr number
local function close_buf_windows(bufnr)
  if not bufnr then
    return
  end

  util.for_each_buf_window(
    bufnr,
    function(window)
      api.nvim_win_close(window, true)
    end
  )
end

local function focus_buf(bufnr)
  if not bufnr then
    return
  end

  local windows = vim.fn.win_findbuf(bufnr)

  if windows[1] then
    api.nvim_set_current_win(windows[1])
  end
end

---
---Closes all windows and deletes a buffer.
---
---@param bufnr number
local function close_buf(bufnr)
  if not bufnr then
    return
  end

  close_buf_windows(bufnr)

  if api.nvim_buf_is_loaded(bufnr) then
    vim.cmd(string.format("bwipeout! %d", bufnr))
  end
end

---
---Clears the entry for a buffer, removes its windoes, deletes the buffer.
---
---@param bufnr number
local function clear_entry(bufnr)
  local entry = M._entries[bufnr]

  close_buf(entry.names_bufnr)
  M._entries[bufnr] = nil
end

---
---Creates a buffer entry if needed.
---
---@param for_buf number
local function setup_buf(for_buf)
  if M._entries[for_buf].names_bufnr then
    return M._entries[for_buf].names_bufnr
  end

  local buf = api.nvim_create_buf(false, false)

  api.nvim_buf_set_option(buf, "buftype", "nofile")
  api.nvim_buf_set_option(buf, "swapfile", false)
  api.nvim_buf_set_option(buf, "buflisted", false)
  api.nvim_buf_set_option(buf, "filetype", "gnamespanel")
  api.nvim_buf_set_var(buf, panel_var, for_buf)

  -- vim.cmd(string.format("augroup GNamesPanel_%d", buf))
  -- vim.cmd "au!"
  -- vim.cmd(string.format([[autocmd CursorMoved <buffer=%d> lua require'gnames.panel'.highlight_name(%d)]], buf, for_buf))
  -- vim.cmd(
  --   string.format(
  --     [[autocmd BufLeave <buffer=%d> lua require'nvim-treesitter-playground.internal'.clear_highlights(%d)]],
  --     buf,
  --     for_buf
  --   )
  -- )
  -- vim.cmd(
  --   string.format(
  --     [[autocmd BufWinEnter <buffer=%d> lua require'nvim-treesitter-playground.internal'.update(%d)]],
  --     buf,
  --     for_buf
  --   )
  -- )
  -- vim.cmd "augroup END"

  for func, mapping in pairs(config.keybindings) do
    api.nvim_buf_set_keymap(
      buf,
      "n",
      mapping,
      string.format(':lua require "gnames.panel".%s(%d)<CR>', func, for_buf),
      {silent = true}
    )
  end

  api.nvim_buf_attach(
    buf,
    false,
    {
      on_detach = function()
        clear_entry(for_buf)
      end
    }
  )

  return buf
end

---
---Contains entries for all panels with their names.
---
M._entries =
  setmetatable(
  {},
  {
    __index = function(tbl, key)
      local entry = rawget(tbl, key)

      if not entry then
        entry = {} --fill up later
        rawset(tbl, key, entry)
      end

      return entry
    end
  }
)

---
---Opens a window for a particular buffer if it has any names highlighted.
---
---@param buf_text nil|number
M._open = function(buf_text)
  buf_text = buf_text or api.nvim_get_current_buf()

  local buf_names = setup_buf(buf_text)
  local current_window = api.nvim_get_current_win()

  M._entries[buf_text].names_bufnr = buf_names
  vim.cmd "vsplit"
  vim.cmd(string.format("buffer %d", buf_names))

  api.nvim_win_set_option(0, "spell", false)
  api.nvim_win_set_option(0, "number", false)
  api.nvim_win_set_option(0, "relativenumber", false)
  api.nvim_win_set_option(0, "cursorline", false)

  api.nvim_set_current_win(current_window)

  return buf_names
end

M._update_names = function(buf_text)
  local names = vim.fn.getbufvar(buf_text, "gnames")
  local buf_names = M._entries[buf_text].names_bufnr
  local render = {}
  for i, name in pairs(names) do
    local record = {lines_num = 5}
    local lines = {}

    lines[#lines + 1] = string.format("%d: %s", i, name.name)
    lines[#lines + 1] = string.format("   line: %d, offset: %d", name.line, name.col)
    lines[#lines + 1] = string.format("   odds: %0.2f, cardinality: %d", name.odds, name.cardinality)
    lines[#lines + 1] = string.format("   verif: %s", name.verif)
    if name.verif ~= "NoMatch" then
      record.lines_num = record.lines_num + 4
      lines[#lines + 1] = string.format("     source: %s", name.source)
      lines[#lines + 1] = string.format("     id: %s", name.match_id)
      lines[#lines + 1] = string.format("     name: %s", name.match_name)
      lines[#lines + 1] = string.format("     edit_distance: %d", name.ed)
    end
    lines[#lines + 1] = ""
    record.lines = lines
    render[#render + 1] = record
  end

  local ls = {}
  for _, rec in pairs(render) do
    for _, l in pairs(rec.lines) do
      ls[#ls + 1] = l
    end
  end
  api.nvim_buf_set_lines(buf_names, 0, -1, false, ls)

  local count = 0
  for i, rec in pairs(render) do
    local grp = config.hi_groups[names[i].verif]
    vim.api.nvim_buf_add_highlight(buf_names, panel_ns, grp, count, 3, -1)
    count = count + #rec.lines
  end
  focus_buf(buf_names)
  vim.cmd([[match Structure /\v[0-9a-z_]+:/]])
end

M.key_down = function(bufnr)
  print(string.format("down %d", bufnr))
end

M.key_up = function(bufnr)
  print(string.format("up %d", bufnr))
end

---
---Opens a panel with names, or closes such panel, if it is opened.
---
---@param buf_text nil|number
M.toggle = function(buf_text)
  buf_text = buf_text or api.nvim_get_current_buf()

  local success, for_buf = pcall(api.nvim_buf_get_var, buf_text, panel_var)

  if success and for_buf then
    buf_text = for_buf
  end

  local buf_names = M._entries[buf_text].names_bufnr

  if buf_names and is_buf_visible(buf_names) then
    close_buf_windows(buf_names)
  else
    M._open(buf_text)
    M._update_names(buf_text)
  end
end

return M
