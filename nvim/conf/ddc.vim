let s:sources = [
    \ 'nvim-lsp',
    \ 'neosnippet',
    \ 'around']

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
        \   'forceCompletionPattern': '\.\w*|:\w*|->\w*' },
        \ }

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
      \ 'useSkkServer': v:true,
      \ 'skkServerResEnc': 'utf-8',
      \ 'skkServerReqEnc': 'utf-8',
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

inoremap <silent><expr> <TAB>
  \ pumvisible() ? '<C-n>' :
  \ (col('.') <= 1 <Bar><Bar> getline('.')[col('.') - 2] =~# '\s') ?
  \ '<tab>' : ddc#manual_complete()

inoremap <expr> <S-TAB> pumvisible() ? '<C-p>' : '<C-h>'

call ddc_nvim_lsp_doc#enable()
call ddc#enable()
