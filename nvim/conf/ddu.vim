call ddu#custom#patch_global({
    \ 'ui': 'ff',
    \ 'sourceOptions': {
    \   '_': {
    \     'matchers': ['matcher_substring']
    \   },
    \   'source': {
    \     'defaultAction': 'execute'
    \   }
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
  nnoremap <buffer><silent> <CR> <Cmd>call ddu#ui#ff#do_action('itemAction')<CR>
  nnoremap <buffer><silent> / <Cmd>call ddu#ui#ff#do_action('openFilterWindow')<CR>
  nnoremap <buffer><silent> <Space> <Cmd>call ddu#ui#ff#do_action('toggleSelectItem')<CR>
  nnoremap <buffer><silent> q <Cmd>call ddu#ui#ff#do_action('quit')<CR>
  nnoremap <buffer><silent> e <Cmd>call ddu#ui#ff#do_action('edit')<CR>
endfunction

function! s:ddu_filter_my_settings() abort
  inoremap <buffer><silent> <CR> <Esc><Cmd>close<CR>
  nnoremap <buffer><silent> <CR> <Cmd>close<CR>
endfunction

augroup DduMyCnf
  autocmd!
  autocmd FileType ddu-ff call <SID>ddu_my_settings()
  autocmd FileType ddu-ff-filter call <SID>ddu_filter_my_settings()
augroup END
