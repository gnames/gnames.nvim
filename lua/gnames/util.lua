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

return M
