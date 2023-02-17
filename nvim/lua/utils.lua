local M = {}

function M.load_local_vimrc()
  -- とりあえず
  vim.cmd([[
    let files = findfile('.vim/vimrc', getcwd().';', -1)
    for i in reverse(filter(files, 'filereadable(v:val)'))
      source `=i`
    endfor
  ]])
end

function M.normalize_punctuation()
  local mode = vim.g.convert_punctuation or 1
  if mode == 1 then
    -- マジでこれしかなさそう
    vim.cmd([[
      :%s/、/，/ge
      :%s/。/．/ge
    ]])
  elseif mode == 2 then
    vim.cmd([[
      :%s/、/,/ge
      :%s/。/./ge
    ]])
  end
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
