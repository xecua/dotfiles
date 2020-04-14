function! NeosnippetHookPostSource() abort
    " keymapping
    imap <C-k> <Plug>(neosnippet_expand_or_jump)
    smap <C-k> <Plug>(neosnippet_expand_or_jump)
    xmap <C-k> <Plug>(neosnippet_expand_target)

    " pumvisible = Pop Up Menu is VISIBLE
    " note: to insert <C-n> literally use "\<C-n\>"
    imap <expr> <tab> (pumvisible() ? "<C-n>" : neosnippet#expandable_or_jumpable() ? "<Plug>(neosnippet_expand_or_jump)" : "<tab>")
    smap <expr> <tab> (neosnippet#expandable_or_jumpable() ? "<Plug>(neosnippet_expand_or_jump)" : "<tab>")

    " スニペット設定ディレクトリ
    let g:neosnippet#snippets_directory = '~/.config/nvim/conf/neosnippet'
endfunction
