local api = vim.api

local M = {}

---
---Runs gnfinder command locally using TSV output format,
---names offsets in bytes, with verification.
---
---@param path string
---@return table of strings
function M.gnfinder(path)
  local cmd = vim.fn.printf("sh -c 'gnfinder -U -v -b -f tsv %s'", path)
  local f = assert(io.popen(cmd))
  vim.defer_fn(
    function()
      f:flush()
      f:close()
    end,
    5000
  )
  local names = {}
  for line in f:lines() do
    names[#names + 1] = line
  end
  return names
end

---
---Merges content of two table and returns a new table
---
---@param t1 table
---@param t2 table
---return table
M.merge_tables = function(t1, t2)
  for k, v in pairs(t2) do
    if (type(v) == "table") and (type(t1[k] or false) == "table") then
      M.merge_tables(t1[k], t2[k])
    else
      t1[k] = v
    end
  end

  return t1
end

---
---Executes a function for window that contains provided buffer.
---
---@param bufnr number
---@fn function
function M.for_each_buf_window(bufnr, fn)
  if not api.nvim_buf_is_loaded(bufnr) then
    return
  end

  for _, window in ipairs(vim.fn.win_findbuf(bufnr)) do
    fn(window)
  end
end

return M
