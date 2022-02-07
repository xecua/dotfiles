call ddu#custom#patch_global({
    \ 'ui': 'std',
    \ 'sourceOptions': {
    \   '_': {
    \     'matchers': ['matcher_substring']
    \   },
    \ },
    \ 'kindOptions': {
    \   'file': {
    \     'defaultAction': 'open',
    \   },
    \   'word': {
    \     'defaultAction': 'append'
    \   },
    \ },
    \ })

function! s:ddu_my_settings() abort
  nnoremap <buffer><silent> <CR> <Cmd>call ddu#ui#std#do_action('itemAction')<CR>
  nnoremap <buffer><silent> / <Cmd>call ddu#ui#std#do_action('openFilterWindow')<CR>
  nnoremap <buffer><silent> <Space> <Cmd>call ddu#ui#std#do_action('toggleSelectItem')<CR>
  nnoremap <buffer><silent> q <Cmd>call ddu#ui#std#do_action('quit')<CR>
endfunction

function! s:ddu_filter_my_settings() abort
  inoremap <buffer><silent> <CR> <Esc><Cmd>close<CR>
  nnoremap <buffer><silent> <CR> <Cmd>close<CR>
endfunction

augroup DduMyCnf
  autocmd!
  autocmd FileType ddu-std call <SID>ddu_my_settings()
  autocmd FileType ddu-std-filter call <SID>ddu_filter_my_settings()
augroup END
