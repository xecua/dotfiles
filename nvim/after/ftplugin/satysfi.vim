set shiftwidth=2
set tabstop=2

let g:quickrun_config.satysfi = {
    \ 'command': 'satysfi',
    \ 'outputter': 'error',
    \ 'outputter/error/error': 'quickfix'
    \ }

augroup SATySFiMyCnf
    au BufWritePost,FileWritePost *.saty QuickRun
augroup END

