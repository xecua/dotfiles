augroup SATySFiMyCnf
  au!
  au BufWritePre,FileWritePre *.saty :call utils#normalize_punctuation()
  au BufWritePost,FileWritePost *.saty QuickRun
augroup END
