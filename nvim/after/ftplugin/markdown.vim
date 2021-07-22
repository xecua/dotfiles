augroup MarkdownMyCnf
  au!
  au BufWritePre,FileWritePre *.md :call utils#normalize_punctuation()
augroup END
