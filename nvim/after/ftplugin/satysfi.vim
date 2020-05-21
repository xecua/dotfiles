set shiftwidth=2
set tabstop=2

function! s:normalize_punctuation()
  :%s/,/，/ge
  :%s/\./．/ge
  :%s/、/，/ge
  :%s/。/．/ge
endfunction

augroup SATySFiMyCnf
    au!
    au BufWritePre,FileWritePre *.saty :call s:normalize_punctuation()
    au BufWritePost,FileWritePost *.saty QuickRun
augroup END

