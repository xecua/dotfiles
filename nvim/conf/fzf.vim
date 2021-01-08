" fzf integration
if isdirectory('/usr/local/opt/fzf')
  " installed with homebrew
  set rtp+=/usr/local/opt/fzf
endif

nnoremap <silent> <Leader>c :Commands<CR>


