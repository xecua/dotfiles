let s:sources = [
    \ 'nvim-lsp',
    \ 'around']

let s:sourceOptions = {
        \ '_': {
        \   'matchers': ['matcher_head'],
        \   'sorters': ['sorter_rank'],
        \ },
        \ 'around': {
        \   'mark': 'A'
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
      \ 'userJisyo': $HOME..'/.skk-jisyo'
      \ }

  if g:os == 'Windows'
    let skkeleton_config['globalJisyo'] = $HOME..'/.skk-jisyo.L'
  endif

  call skkeleton#config(skkeleton_config)

endif

call ddc#custom#patch_global('sources', s:sources)
call ddc#custom#patch_global('sourceOptions', s:sourceOptions)

inoremap <silent><expr> <TAB>
  \ pumvisible() ? '<C-n>' :
  \ (col('.') <= 1 <Bar><Bar> getline('.')[col('.') - 2] =~# '\s') ?
  \ '<tab>' : ddc#manual_complete()

inoremap <expr> <S-TAB> pumvisible() ? '<C-p>' : '<C-h>'

call ddc_nvim_lsp_doc#enable()
call ddc#enable()
