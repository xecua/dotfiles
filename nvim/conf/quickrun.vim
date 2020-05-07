" _: default configuration for all filetypes
let g:quickrun_config._ = {
  \ '_': {
  \   'runner' : 'vimproc',
  \   'runner/vimproc/updatetime' : 40,
  \   'outputter' : 'error',
  \   'outputter/error/success' : 'buffer',
  \   'outputter/error/error'   : 'quickfix',
  \   'outputter/buffer/split' : ':botright 8sp',
  \   'outputter/buffer/close_on_empty' : 1,
  \ },
  \ 'cpp': {
  \   'command': 'g++-9'
  \ },
  \ 'tex': {
  \   'command': 'latexmk'
  \ },
  \ 'satysfi': {
  \   'command': 'satysfi'
  \ }
\}

" 実行時に前回の表示内容をクローズ&保存してから実行
" let g:quickrun_no_default_key_mappings = 1

" QuickRun and view compile result quickly
nnoremap <silent> <F5> :QuickRun -mode n<CR>
vnoremap <silent> <F5> :QuickRun -mode v<CR>
