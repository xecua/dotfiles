local M = {}

function M.normalize_punctuation()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, true)
  local new_lines = {}
  for i, line in ipairs(lines) do
    new_lines[i] = vim.fn.substitute(vim.fn.substitute(line, "、", "，", "ge"), "。", "．", "ge")
  end
  vim.api.nvim_buf_set_lines(0, 0, -1, true, new_lines)
end

function M.find(pattern, list)
  for i, item in ipairs(list) do
    if pattern == item then
      return i
    end
  end

  return -1
end

function M.get_os_string()
  if vim.fn.has("win64") == 1 or vim.fn.has("win32") == 1 or vim.fn.has("win16") == 1 then
    return "Windows"
  else
    local uname = vim.fn.system("uname"):gsub("\n", "")
    if uname == "Linux" and string.find(vim.fn.readfile("/proc/version")[1], "microsoft") ~= nil then
      return "WSL"
    else
      return uname
    end
  end
end

return M
