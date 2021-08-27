local M = {names = {}}

local util = require "gnames.util"
local str = require "gnames.string"

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
          source = row[17]
        }
        M.names[#M.names + 1] = name
      end
    end
    count = count + 1
  end
  print(string.format("Found and highlighted %d possible names occurrences", #M.names))

  local starts_line, ends_line, line_len, pos, name_len, cmd
  for i, n in pairs(M.names) do
    starts_line = vim.fn.byte2line(n.starts)
    ends_line = vim.fn.byte2line(n.ends)
    line_len = vim.fn.line2byte(starts_line)
    pos = n.starts - line_len + 1
    name_len = n.ends - n.starts
    M.names[i].line = starts_line
    M.names[i].line_offset = pos
    cmd = string.format('call matchaddpos("GnName", [[%d, %d, %d]])', starts_line, pos, name_len)
    vim.cmd(cmd)

    if starts_line ~= ends_line then
      pos = 1
      line_len = vim.fn.line2byte(ends_line)
      name_len = n.ends + 1 - line_len
      cmd = string.format('call matchaddpos("GnName", [[%d, %d, %d]])', ends_line, 1, name_len)
      vim.cmd(cmd)
    end
  end
end

---
---Finds scientific names in current buffer and highlights them.
---Sets the buffer's gnames variable that contains found names data.
---
M.find = function()
  M.clear()
  local path = vim.fn.expand("%")
  local names = util.gnfinder(path)
  if #names > 1 then
    M._process(names)
    vim.b.gnames = M.names
  end
end

---
---Cleans up all highlights and empties the buffer's gnames table.
---
M.clear = function()
  vim.b.gnames = {}
  vim.cmd("call clearmatches()")
end

return M
