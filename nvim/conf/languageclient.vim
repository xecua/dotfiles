let g:LanguageClient_serverCommands = {
    \ 'rust': ['rls'],
    \ 'vue': ['vls'],
    \ 'swift': ['xcrun', 'sourcekit-lsp'],
    \ 'tex': ['texlab'],
    \ 'python': ['pyls'],
    \ 'haskell': ['hie-wrapper', '--lsp'],
    \ 'c': ['clangd'],
    \ 'cpp': ['clangd'],
    \ 'd': ['serve-d'],
    \ 'vim': ['vim-language-server', '--stdio'],
    \ 'typescript': ['typescript-language-server', '--stdio'],
    \ 'typescript.tsx': ['typescript-language-server', '--stdio'],
    \ 'typescriptreact': ['typescript-language-server', '--stdio'],
    \ }

if g:os == 'darwin' || g:os == 'linux'
  let s:jdt_ls_cache_dir = $XDG_CACHE_HOME.'/eclipse/jdt-data'
  if !isdirectory(s:jdt_ls_cache_dir)
    call mkdir(s:jdt_ls_cache_dir, 'p')
  endif

  let s:jdt_ls_data_dir = $HOME.'/.local/lib/eclipse-jdt-ls'
  if g:os == 'darwin'
    let s:jdt_ls_config_dir = s:jdt_ls_data_dir.'/config_mac'
  elseif g:os == 'linux'
    let s:jdt_ls_config_dir = s:jdt_ls_data_dir.'/config_linux'
  endif

  let s:equinox_launcher_path = glob(s:jdt_ls_data_dir.'/plugins/org.eclipse.equinox.launcher_*')

  let g:LanguageClient_serverCommands['java'] = [
    \ 'java',
    \ '-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=1044',
    \ '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    \ '-Dosgi.bundles.defaultStartLevel=4',
    \ '-Declipse.product=org.eclipse.jdt.ls.core.product',
    \ '-Dlog.protocol=true',
    \ '-Dlog.level=ALL',
    \ '-noverify',
    \ '-Xmx1G',
    \ '-jar',
    \ s:equinox_launcher_path,
    \ '-configuration',
    \ s:jdt_ls_config_dir,
    \ '-data',
    \ s:jdt_ls_data_dir
    \ ]
endif

" make map for only supported filetypes(from help)
function LC_maps()
  if has_key(g:LanguageClient_serverCommands, &filetype)
    nnoremap <buffer> <silent> <Leader>m :call LanguageClient#textDocument_hover()<cr>
    nnoremap <buffer> <silent> <Leader>M :call LanguageClient#textDocument_definition()<CR>
    nnoremap <buffer> <silent> <F2> :call LanguageClient#textDocument_rename()<CR>
  endif
endfunction

augroup LanguageClientMyCnf
  autocmd!
  autocmd FileType * call LC_maps()
augroup END



