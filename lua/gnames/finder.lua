local M = {
  gnfinder_url = "https://gnfinder.globalnames.org/api/v1",
  len = 0,
  cur_line = 0,
  cur_len = 0,
  cur_pos = 0
}

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
  print(vim.fn.printf("Found and highlightedj %d possible names occurrences", #names))

  for _, n in pairs(names) do
    M.cur_line = vim.fn.byte2line(n.starts)
    M.len = vim.fn.line2byte(M.cur_line)
    M.cur_pos = n.starts - M.len + 1
    local hi = vim.fn.printf('call matchaddpos("GnName", [[%d, %d, %d]])', M.cur_line, M.cur_pos, n.ends - n.starts)
    vim.cmd(hi)
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
