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

return M
