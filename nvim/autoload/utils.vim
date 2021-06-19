function! utils#normalize_punctuation()
  if get(g:, 'convert_punctuation', 1) == 1
    :%s/、/，/ge
    :%s/。/．/ge
  else
    :%s/、/,/ge
    :%s/。/./ge
  endif
endfunction
