" _: default configuration for all filetypes
let g:quickrun_config = {
  \ '_': {
  \   'runner' : 'vimproc',
  \   'runner/vimproc/updatetime' : 40,
  \   'outputter' : 'error',
  \   'outputter/error/error' : 'quickfix',
  \   'outputter/quickfix/into': 1,
  \ },
  \ 'cpp': {
  \   'command': 'g++-10'
  \ },
  \ 'tex': {
  \   'command': 'latexmk',
  \   'commandopt': '-lualatex'
  \ },
  \ 'satysfi': {
  \   'command': 'satysfi'
  \ },
  \ 'rust': {
  \    'type': 'rust/cargo'
  \ }
\}
" \   'outputter/error/success' : 'message',

" default keymappings:
" <Leader>r <Plug>(quickrun)
" to disable this,uncomment below
" let g:quickrun_no_default_key_mappings = 1

" close error window on success
let s:close_quickfix_hook = {
    \ "name": "close_quickfix_on_success",
    \ "kind": "hook"
    \ }

function! s:close_quickfix_hook.on_success(session, context)
    :cclose
endfunction

call quickrun#module#register(s:close_quickfix_hook, 1)
unlet s:close_quickfix_hook

" QuickRun and view compile result quickly
let g:quickrun_no_default_key_mappings = 1
nnoremap <silent> <F5> :QuickRun -mode n<CR>
vnoremap <silent> <F5> :QuickRun -mode v<CR>

