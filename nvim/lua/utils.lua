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
  if vim.g.convert_punctuation ~= 0 then
    -- マジでこれしかなさそう
    vim.cmd([[
      :%s/、/，/ge
      :%s/。/．/ge
    ]])
  else
    vim.cmd([[
      :%s/、/,/ge
      :%s/。/./ge
    ]])
  end
end

return M
