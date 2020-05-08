let g:LanguageClient_serverCommands = {
    \ 'rust': ['~/.cargo/bin/rustup', 'run', 'stable', 'rls'],
    \ 'vue': ['vls'],
    \ 'swift': ['xcrun', 'sourcekit-lsp'],
    \ 'tex': ['texlab'],
    \ 'python': ['pyls'],
    \ }


" make map for only supported filetypes(from help)
function LC_maps()
  if has_key(g:LanguageClient_serverCommands, &filetype)
    nnoremap <buffer> <silent> <Leader>m :call LanguageClient#textDocument_hover()<cr>
    nnoremap <buffer> <silent> <Leader>M :call LanguageClient#textDocument_definition()<CR>
    nnoremap <buffer> <silent> <F2> :call LanguageClient#textDocument_rename()<CR>
  endif
endfunction

autocmd FileType * call LC_maps()



