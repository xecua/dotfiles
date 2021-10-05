augroup FernSetup
  autocmd!
  autocmd StdinReadPre * let s:std_in=1
  autocmd VimEnter * ++nested Fern %:h | if argc() == 0 || exists("s:std_in") | wincmd p | endif
augroup END

let g:fern#renderer = 'nerdfont'

nnoremap <silent><C-n> :<C-u>Fern . -drawer -toggle<CR>
