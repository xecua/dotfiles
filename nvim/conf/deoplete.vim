let g:deoplete#enable_at_startup = 1

function! DeopleteHookPostSource() abort
  " disable preview window feature(because it makes completion too slow)
  set completeopt-=preview

  inoremap <expr> <S-tab> pumvisible() ? "\<UP>" : "\<S-Tab>"
endfunction
