function! NeosnippetHookPostSource() abort
  " <tab>で次のプレースホルダにジャンプ
  imap <expr> <tab>
      \ pumvisible()
      \ ? "\<C-n>"
      \ : neosnippet#jumpable()
      \   ? "\<Plug>(neosnippet_jump)"
      \   : "<tab>"

  " スニペット設定ディレクトリ
  let g:neosnippet#snippets_directory = g:vim_home . '/neosnippet'
endfunction

