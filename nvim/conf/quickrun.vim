let g:quickrun_config = {
    \ '_' : {
        \ 'runner' : 'vimproc',
        \ 'runner/vimproc/updatetime' : 40,
        \ 'outputter' : 'error',
        \ 'outputter/error/success' : 'buffer',
        \ 'outputter/error/error'   : 'quickfix',
        \ 'outputter/buffer/split' : ':botright 8sp',
        \ 'outputter/buffer/close_on_empty' : 1,
    \ }
\}

" 実行時に前回の表示内容をクローズ&保存してから実行
" let g:quickrun_no_default_key_mappings = 1
" nmap <Leader>r :cclose<CR>:write<CR>:QuickRun -mode n<CR>


let g:quickrun_config.cpp = {
            \ 'command' : 'g++',
            \ }
"\ 'cmdopt' : '-std=c++17'

" QuickRun and view compile result quickly (but don't preview pdf file)
nnoremap <silent><F5> :QuickRun<CR>

