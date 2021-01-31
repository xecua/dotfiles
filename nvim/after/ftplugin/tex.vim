" lexima options for TeX
call lexima#add_rule({'char': '(', 'at': '\\\%#', 'input_after': '\)'})
call lexima#add_rule({'char': '[', 'at':'\\\%#', 'input_after': '\]'})
call lexima#add_rule({'char': '`', 'at': '`\%#', 'input_after': ''''''})
call lexima#add_rule({'char': '`', 'at': '`\%#`', 'input': '<right>''''<left><left>'})

function! s:normalize_punctuation()
  if get(g:, 'convert_punctuation', 0) == 1
    :%s/、/，/ge
    :%s/。/．/ge
  endif
endfunction

" auto compile on save
augroup TeXMyCnf
    au!
    au BufWritePre,FileWritePre *.tex :call s:normalize_punctuation()
    au BufWritePost,FileWritePost *.tex QuickRun
augroup END

" disable conceal
let g:tex_conceal = ''
