" lexima options for TeX
call lexima#add_rule({'char': '$', 'input_after': '$', 'filetype': 'tex'})
call lexima#add_rule({'char': '$', 'at': '\%#\$', 'leave': 1, 'filetype': 'tex'})
call lexima#add_rule({'char': '<BS>', 'at': '\$\%#\$', 'delete': 1, 'filetype': 'tex'})
function! s:normalize_punctuation()
  :%s/,/，/ge
  :%s/\./．/ge
  :%s/、/，/ge
  :%s/。/．/ge
endfunction

" auto compile on save
augroup TeXMyCnf
    au!
    au BufWritePre,FileWritePre *.tex :call s:normalize_punctuation()
    au BufWritePost,FileWritePost *.tex QuickRun
augroup END


