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

local u = require "gnames.util"
local curl = require("plenary.curl")

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

M._process = function(body, _)
  local names = {}

  local rows = split(body, "\n")
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
  print(vim.fn.printf("Found %d possible names occurrences", #names))

  for i, n in pairs(names) do
    print(vim.fn.printf("%d: %d, %d", i, n.starts, n.ends))
    M.cur_line = vim.fn.byte2line(n.starts)
    M.len = vim.fn.line2byte(M.cur_line)
    M.cur_pos = n.starts - M.len + 1
    print(vim.fn.printf("line %d, %d, %d", M.cur_line, M.cur_pos, n.ends - n.starts))
    local hi = vim.fn.printf('call matchaddpos("GnName", [[%d, %d, %d]])', M.cur_line, M.cur_pos, n.ends - n.starts)
    vim.cmd(hi)
  end
end

M.find = function()
  local txt_data = u.txt()
  local txt = txt_data.text
  local body =
    vim.fn.json_encode(
    {
      text = txt,
      bytesOffset = true,
      verification = true,
      format = "tsv"
    }
  )
  local resp =
    curl.post(
    M.gnfinder_url .. "/find",
    {
      headers = {
        content_type = "application/json"
      },
      body = body
    }
  )
  if resp.status == 200 then
    -- txt_data.len is a table that contains length of all lines of the text
    M._process(resp.body, txt_data.len)
  end
end

return M
