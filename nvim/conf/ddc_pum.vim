let s:sources = [
    \ 'nvim-lsp',
    \ 'neosnippet',
    \ 'around',
    \ 'file']

let s:sourceOptions = {
        \ '_': {
        \   'matchers': ['matcher_head'],
        \   'sorters': ['sorter_rank'],
        \ },
        \ 'around': {
        \   'mark': 'A'
        \ },
        \ 'neosnippet': {
        \   'dup': v:true,
        \   'mark': 'snip'
        \ },
        \ 'nvim-lsp': {
        \   'mark': 'LSP',
        \   'forceCompletionPattern': '\.\w*|:\w*|->\w*'
        \ },
        \ 'file': {
        \   'mark': 'F',
        \   'forceCompletionPattern': '\S/\S*'
        \ }
        \ }

" ddc-file: for windows
call ddc#custom#patch_filetype(
    \ ['ps1', 'dosbatch', 'autohotkey', 'registry'], {
    \ 'sourceOptions': {
    \   'file': {
    \     'forceCompletionPattern': '\S\\\S*',
    \   },
    \ },
    \ 'sourceParams': {
    \   'file': {
    \     'mode': 'win32',
    \   },
    \ }})

if exists('g:neovide') " or any other conditions
  let s:sources += ['skkeleton']
  let s:sourceOptions.skkeleton = {
      \ 'mark': 'skk',
      \ 'matchers': ['skkeleton'],
      \ 'sorters': []
      \ }

  imap <C-j> <Plug>(skkeleton-enable)
  cmap <C-j> <Plug>(skkeleton-enable)
  lmap <C-j> <Plug>(skkeleton-enable)

  let skkeleton_config = {
      \ 'eggLikeNewline': v:true,
      \ 'immediatelyCancel': v:false,
      \ 'showCandidatesCount': 1,
      \ 'globalJisyo': $HOME..'/.skk-jisyo',
      \ 'globalJisyoEncoding': 'utf-8',
      \ }

  call skkeleton#config(skkeleton_config)

endif

augroup DDCMyCnf
  au!
  " close preview after completion
  autocmd CompleteDone * silent! pclose!
augroup END

call ddc#custom#patch_global('sources', s:sources)
call ddc#custom#patch_global('sourceOptions', s:sourceOptions)
call ddc#custom#patch_global('completionMenu', 'pum.vim')

inoremap <silent><expr> <Tab>
  \ pum#visible() ? '<Cmd>call pum#map#insert_relative(+1)<CR>' :
  \ (col('.') <= 1 <bar><bar> getline('.')[col('.') - 2] =~# '\s') ?
  \ '<Tab>' : ddc#manual_complete()
inoremap <expr> <S-tab> pum#visible() ? '<Cmd>call pum#map#insert_relative(-1)<CR>' : '<C-h>'
inoremap <C-n> <Cmd>call pum#map#insert_relative(+1)<CR>
inoremap <C-p> <Cmd>call pum#map#insert_relative(-1)<CR>
inoremap <C-y> <Cmd>call pum#map#confirm()<CR>
inoremap <C-e> <Cmd>call pum#map#cancel()<CR>

call ddc#enable()
