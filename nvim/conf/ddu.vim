call ddu#custom#patch_global({
    \ 'ui': 'std',
    \ 'sourceOptions': {
    \   '_': {
    \     'matchers': ['matcher_fzf']
    \   },
    \ },
    \ 'sourceParams': {
    \   'rg': {
    \     'args': ['--column', '--no-heading']
    \   },
    \ }
    \ })

function! s:ddu_my_settings() abort
  nnoremap <buffer><silent> <cr> <cmd>call ddu#ui#std#do_action('itemAction')<cr>
  nnoremap <buffer><silent> <space> <cmd>call ddu#ui#std#do_action('toggleSelectItem')<cr>
  nnoremap <buffer><silent> q <cmd>call ddu#ui#std#do_action('quit')<cr>
endfunction

augroup DduMyCnf
  autocmd!
  autocmd FileType ddu-std call <SID>ddu_my_settings()
augroup END
