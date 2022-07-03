local M = {}

function M.load_local_vimrc()
  -- とりあえず
  vim.cmd[[
    let files = findfile('.vim/vimrc', getcwd().';', -1)
    for i in reverse(filter(files, 'filereadable(v:val)'))
      source `=i`
    endfor
  ]]
end

function M.normalize_punctuation()
  -- とりあえず
  vim.cmd[[
    if get(g:, 'convert_punctuation', 1) == 1
      :%s/、/，/ge
      :%s/。/．/ge
    else
      :%s/、/,/ge
      :%s/。/./ge
    endif
  ]]
end

return M
