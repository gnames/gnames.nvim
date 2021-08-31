local M = {names = {}}

local util = require "gnames.util"
local config = require "gnames.config"
local str = require "gnames.string"

local text_ns = vim.api.nvim_create_namespace(config.text_ns)

---
---Takes TSV rows with names information from gnfinder output and highlights
---finds names in the buffer and highlights them.
---
---@param rows table of tables
M._process = function(rows)
  M.names = {}
  if #rows < 2 then
    print("No names found")
    return
  end

  local count = 1
  local header = {}
  for _, v in pairs(rows) do
    if count == 1 then
      header = str.split(v, "\t")
    elseif count > 1 then
      local row = str.split(v, "\t")
      if #row == #header then
        local name = {
          name = row[3],
          starts = row[4] + 1,
          ends = row[5] + 1,
          odds = row[6],
          cardinality = row[7],
          annot = row[8],
          verif = row[11],
          ed = row[12],
          match_name = row[13],
          match_id = row[15],
          source = row[17],
          hls = {}
        }
        M.names[#M.names + 1] = name
      end
    end
    count = count + 1
  end
  print(string.format("Found and highlighted %d possible names occurrences", #M.names))

  local line_start, line_end, line_len, pos_start, pos_end
  for i, n in pairs(M.names) do
    line_start = vim.fn.byte2line(n.starts)
    line_end = vim.fn.byte2line(n.ends)
    line_len = vim.fn.line2byte(line_start)
    pos_start = n.starts - line_len
    pos_end = n.ends - line_len
    if line_end ~= line_start then
      pos_end = -1
    end
    local grp = config.hi_groups[n.verif]
    local buf = vim.api.nvim_get_current_buf()
    M.names[i].hls[#M.names[i].hls + 1] = {line = line_start - 1, starts = pos_start, ends = pos_end}
    vim.api.nvim_buf_add_highlight(buf, text_ns, grp, line_start - 1, pos_start, pos_end)

    if line_start ~= line_end then
      pos_end = n.ends - vim.fn.line2byte(line_end)
      M.names[i].hls[#M.names[i].hls + 1] = {line = line_end - 1, starts = 0, ends = pos_end}
      vim.api.nvim_buf_add_highlight(buf, text_ns, grp, line_end - 1, 0, pos_end)
    end
    M.names[i].line = line_start
    M.names[i].col = vim.fn.charidx(vim.fn.getline(line_start), pos_start + 1)
  end
end

---
---Finds scientific names in current buffer and highlights them.
---Sets the buffer's gnames variable that contains found names data.
---
M.find = function()
  M.clear()
  local path = vim.fn.expand("%")
  local gnf_names = util.gnfinder(path)
  if #gnf_names > 1 then
    M._process(gnf_names)
    local buf = vim.api.nvim_get_current_buf()

    local panel = require("gnames.names")
    panel._entries[buf].names = M.names
    panel.toggle(buf)
  end
end

---
---Cleans up all highlights and empties the buffer's gnames table.
---
M.clear = function()
  vim.b.gnames = {}
  vim.api.nvim_buf_clear_namespace(0, text_ns, 0, -1)
  vim.cmd("call clearmatches()")
end

return M
