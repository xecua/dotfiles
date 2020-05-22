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

augroup NeoSnippetMyCnf
  au!
  " <CR>でsnippet展開。leximaが上書きするのでIntertEnterで無理やり
  au InsertEnter * imap <expr> <CR>
    \ (pumvisible()
    \ ? (neosnippet#expandable()
    \   ? "\<Plug>(neosnippet_expand)"
    \   : deoplete#close_popup())
    \ : lexima#expand('<CR>', 'i'))
augroup END

