let g:deoplete#enable_at_startup = 1

function! DeopleteHookPostSource() abort
  " disable preview window feature(because it makes completion too slow)
  set completeopt-=preview
  " `popup` is not implemented in Neovim0.4.4...
  set completeopt+=menuone,noinsert

  inoremap <expr> <S-tab> pumvisible() ? "\<UP>" : "\<S-Tab>"
endfunction



