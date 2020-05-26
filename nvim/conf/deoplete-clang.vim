function! DeopleteClangHookSource() abort
  if g:os == "Darwin"
    let s:clang_path = '/usr/local/opt/llvm'
    let g:deoplete#sources#clang#libclang_path = s:clang_path.'/lib/libclang.dylib'
    let g:deoplete#sources#clang#clang_header = s:clang_path.'/include/clang'
  else
    let g:deoplete#sources#clang#libclang_path = ''
    let g:deoplete#sources#clang#clang_header = ''
  endif
endfunction
