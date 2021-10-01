call ddc#custom#patch_global('sources', [
    \ 'nvim-lsp',
    \ 'around'
    \ ])
call ddc#custom#patch_global('sourceOptions', {
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
      \ })

inoremap <silent><expr> <TAB>
  \ pumvisible() ? '<C-n>' :
  \ (col('.') <= 1 <Bar><Bar> getline('.')[col('.') - 2] =~# '\s') ?
  \ '<tab>' : ddc#manual_complete()

inoremap <expr> <S-TAB> pumvisible() ? '<C-p>' : '<C-h>'

call ddc_nvim_lsp_doc#enable()
call ddc#enable()
