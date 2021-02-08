let g:coc_global_extensions = [
    \ 'coc-highlight',
    \ 'coc-vimlsp',
    \ 'coc-tabnine',
    \ 'coc-json',
    \ 'coc-flutter',
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

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> <leader>m :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" Make <CR> auto-select the first completion item and notify coc.nvim to
" format on enter, <cr> could be remapped by other vim plugin
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

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

function s:setup_coc() abort
  call coc#config('latex.forwardSearch', {
       \   'executable': '/Applications/Skim.app/Contents/SharedSupport/displayline',
       \   'args': ['%l', '%p', '%f']
       \ })
  call coc#config('python.formatting', {
      \   'yapfPath': '/usr/local/bin/yapf'
      \ })
endfunction
augroup CocConfig
  au! VimEnter * call <SID>setup_coc()
augroup END
