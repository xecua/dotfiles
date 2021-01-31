let g:coc_global_extensions = [
    \ 'coc-vimlsp',
    \ 'coc-tabnine',
    \ 'coc-json',
    \ 'coc-tsserver',
    \ 'coc-eslint',
    \ 'coc-prettier',
    \ 'coc-java',
    \ 'coc-metals',
    \ 'coc-pyright',
    \ 'coc-rust-analyzer',
    \ 'coc-texlab',
    \ 'coc-toml',
    \ 'coc-clangd',
    \ 'coc-neosnippet'
    \ ]

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

imap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>"
      \ : neosnippet#jumpable() ? "\<Plug>(neosnippet_jump)"
      \ : <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

command! -nargs=0 Format :call CocAction('format')
" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

nmap <F2> <Plug>(coc-rename)
nmap <silent> <leader>i <Plug>(coc-codeaction)
nmap <silent> <leader>F <Plug>(coc-fix-current)

xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)
