function! DeopleteClangHookSource() abort
  if g:os == "Darwin"
    let g:deoplete#sources#clang#libclang_path = '/usr/lib/llvm-6.0/lib/libclang-6.0.so.1'
    let g:deoplete#sources#clang#clang_header = '/usr/include/clang'
  else
    let g:deoplete#sources#clang#libclang_path = ''
    let g:deoplete#sources#clang#clang_header = ''
  endif
endfunction