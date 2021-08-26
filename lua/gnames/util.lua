local M = {}

function M.txt()
  local content = vim.api.nvim_buf_get_lines(0, 0, vim.api.nvim_buf_line_count(0), false)
  local txt = table.concat(content, "\n")
  local lenghts = {}
  for i, line in pairs(content) do
    lenghts[i] = string.len(line) + 1
  end
  return {text = txt, len = lenghts}
end

-- Merges content of two table and returns a new table
function M.merge_tables(t1, t2)
  for k, v in pairs(t2) do
    if (type(v) == "table") and (type(t1[k] or false) == "table") then
      M.merge_tables(t1[k], t2[k])
    else
      t1[k] = v
    end
  end

  return t1
end

return M
