local M = {len = 0, cur_line = 0, cur_len = 0, cur_pos = 0}
local u = require "gnames.util"
local curl = require("plenary.curl")

M._process = function(body, lenghts)
  local pos = {}
  body = string.gsub(body, "^.*%[", "")
  body = string.gsub(body, "%].*", "")
  body = string.gsub(body, "},{", "}щ{")
  local names = vim.fn.split(body, "щ")
  for _, v in pairs(names) do
    local name = vim.fn.json_decode(v)
    pos[#pos + 1] = {starts = name["start"], ends = name["end"]}
  end

  M.cur_line = 1
  M.cur_len = lenghts[1]
  for _, p in pairs(pos) do
    print(vim.fn.printf("%d-%d, start: %d, line: %d, len: %d", p.starts, p.ends, M.cur_pos, M.cur_line, M.cur_len))
    -- we need to find the line which where index is located
    if p.starts > M.cur_len + M.len then
      M.adjust_cur(lenghts, p.starts)
    end
    M.cur_pos = p.starts - M.len + 1
    print(vim.fn.printf("%d-%d, start: %d, line: %d, len: %d", p.starts, p.ends, M.cur_pos, M.cur_line, M.cur_len))
    print("")
    local hi = vim.fn.printf('call matchaddpos("GnName", [[%d, %d, %d]])', M.cur_line, M.cur_pos, p.ends - p.starts)
    vim.cmd(hi)
  end
end

M.adjust_cur = function(lenghts, starts)
  -- lengths is a table where line is line number and line_len is the
  -- length of the line in bytes
  for line, line_len in pairs(lenghts) do
    if line > M.cur_line and starts > M.len + M.cur_len then
      M.cur_line = M.cur_line + 1
      M.len = M.len + M.cur_len
      M.cur_len = line_len
    elseif line > M.cur_line and starts > M.len and starts < M.len + M.cur_len then
      M.cur_line = M.cur_line + 1
      M.cur_len = line_len
      return
    end
  end
  return
end

M.find = function()
  local txt_data = u.txt()
  local txt = txt_data.text
  local body =
    vim.fn.json_encode(
    {
      text = txt,
      bytesOffset = true
    }
  )
  local resp =
    curl.post(
    -- "https://gnfinder.globalnames.org/api/v1/find",
    "http://localhost:8080/api/v1/find",
    {
      headers = {
        content_type = "application/json"
      },
      body = body
    }
  )
  if resp.status == 200 and string.find(resp.body, "%[") then
    -- txt_data.len is a table that contains length of all lines of the text
    M._process(resp.body, txt_data.len)
  end
end

return M
