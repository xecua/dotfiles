" disable LSP feature
if has('nvim-0.5')
  let g:ale_disable_lsp = 1
endif

" let g:ale_sign_error = '⨉'
" let g:ale_sign_warning = '⚠'
let g:ale_echo_msg_format = '[%linter%] [%severity%] %s'

let g:ale_lint_on_save = 1
let g:ale_lint_on_text_changed = 'never'

let g:ale_set_loclist = 0
let g:ale_set_quickfix = 0
let g:ale_open_list = 0
let g:ale_keep_list_window_open = 0

let g:ale_linters = {
    \ 'rust': [],
    \ 'swift': [],
    \ 'tex': [],
    \ 'python': ['yapf'],
    \ 'vue': [],
    \ }

" prefix for ALE
nmap [ale] <Nop>
" won't conflict with neocomplete
map <C-k> [ale]

nmap <silent> [ale]<C-k> <Plug>(ale_previous)
nmap <silent> [ale]<C-j> <Plug>(ale_next)
