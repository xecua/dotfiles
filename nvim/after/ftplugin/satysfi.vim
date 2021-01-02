setl shiftwidth=2
setl tabstop=2

function! s:normalize_punctuation()
  " 英語ドキュメントのときは0にする
  if get(g:, 'is_japanese_document', 1) == 1
    :%s/、/，/ge
    :%s/。/．/ge
  else
    :%s/、/,/ge
    :%s/。/./ge
  endif
endfunction

augroup SATySFiMyCnf
    au!
    au BufWritePre,FileWritePre *.saty :call s:normalize_punctuation()
    au BufWritePost,FileWritePost *.saty QuickRun
augroup END

