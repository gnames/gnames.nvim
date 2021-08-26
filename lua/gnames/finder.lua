local M = {}

local name = {
  starts = 0,
  ends = 0
}

local util = require "gnames.util"

local split = function(s, delimiter)
  local result = {}
  local from = 1
  local delim_from, delim_to = string.find(s, delimiter, from)
  while delim_from do
    table.insert(result, string.sub(s, from, delim_from - 1))
    from = delim_to + 1
    delim_from, delim_to = string.find(s, delimiter, from)
  end
  table.insert(result, string.sub(s, from))
  return result
end

M._process = function(rows)
  local names = {}

  if #rows < 2 then
    print("No names found")
    return
  end

  local count = 1
  local header = {}
  for _, v in pairs(rows) do
    if count == 1 then
      header = split(v, "\t")
    elseif count > 1 then
      local row = split(v, "\t")
      if #row == #header then
        name = {starts = row[4] + 1, ends = row[5] + 1}
        names[#names + 1] = name
      end
    end
    count = count + 1
  end
  print(vim.fn.printf("Found and highlighted %d possible names occurrences", #names))

  local starts_line = 0
  local ends_line = 0
  local line_len = 0
  local pos = 0
  local name_len = 0
  local cmd = ""
  for _, n in pairs(names) do
    starts_line = vim.fn.byte2line(n.starts)
    ends_line = vim.fn.byte2line(n.ends)
    line_len = vim.fn.line2byte(starts_line)
    pos = n.starts - line_len + 1
    name_len = n.ends - n.starts
    cmd = vim.fn.printf('call matchaddpos("GnName", [[%d, %d, %d]])', starts_line, pos, name_len)
    vim.cmd(cmd)

    if starts_line ~= ends_line then
      pos = 1
      line_len = vim.fn.line2byte(ends_line)
      name_len = n.ends + 1 - line_len
      cmd = vim.fn.printf('call matchaddpos("GnName", [[%d, %d, %d]])', ends_line, 1, name_len)
      vim.cmd(cmd)
    end
  end
end

M.find = function()
  local path = vim.fn.expand("%")
  local names = util.gnfinder(path)
  if #names > 1 then
    -- txt_data.len is a table that contains length of all lines of the text
    M._process(names)
  end
end

return M
