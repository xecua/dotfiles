let g:neosnippet#snippets_directory = g:vim_home .. '/neosnippet'

imap <C-k> <Plug>(neosnippet_expand_or_jump)

" call deoppet#initialize()
" call deoppet#custom#option('snippets',
"     \ map(globpath(&runtimepath, 'neosnippets', 1, 1),
"     \     { _, val -> { 'path': val } }))
" imap <silent> <C-k> <Plug>(deoppet_expand)
" imap <silent> <C-f> <Plug>(deoppet_jump_forward)
" imap <silent> <C-b> <Plug>(deoppet_jump_backward)
