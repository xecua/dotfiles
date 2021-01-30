let g:lightline = {
   \ 'colorscheme': 'wombat',
   \   'tabline': {
   \     'left': [['tabs']],
   \     'right': [['close'], ['time']]
   \   },
   \ 'separator': { 'left': "\ue0b0", 'right': "\ue0b2" },
   \ 'subseparator': { 'left': "\ue0b1", 'right': "\ue0b3" },
   \ 'active': {
   \   'left': [['mode', 'paste'], ['gitbranch', 'readonly', 'filename', 'modified']],
   \   'right': [['lineinfo'], ['fileformat', 'fileencoding', 'filetype']]
   \ },
   \ 'inactive': {
   \   'left': [['filename']],
   \   'right': [['lineinfo']],
   \ },
   \ 'component': {
   \   'time': '%{strftime(''%H:%M'')}'
   \ },
   \ 'component_function': {
   \   'readonly': 'LightLineReadonly',
   \   'modified': 'LightLineModified',
   \   'filename': 'LightLineFilename',
   \   'mode': 'LightLineMode',
   \   'filetype': 'LightLineFiletype',
   \   'fileformat': 'LightLineFileformat',
   \   'fileencoding': 'LightLineFileencoding',
   \   'gitbranch': 'LightLineGitBranch',
   \ }
   \ }

function! LightLineGitBranch() abort
  " 0xff7a1  git icon on Cica
  return &ft =~ 'defx\|help\|denite' ? ''
      \ : nr2char('0xff7a1').FugitiveHead()
endfunction

function LightLineModified() abort
  return &ft =~ 'defx\|help\|denite' ? ''
      \ : &modified ? '+'
      \ : ''
endfunction

function! LightLineFilename() abort
  if &ft == 'denite'
    return denite#get_status('sources')
  elseif &ft =~ 'defx\|help'
    return ''
  endif
  let filename = expand('%')
  if strlen(filename) == 0
    return '[No Name]'
  endif
  return winwidth(0) > 100 ? expand('%:~'): filename
endfunction

function! LightLineReadonly() abort
  return &ft =~ 'defx\|help\|denite' ? ''
      \ : &readonly ? '[readonly]'
      \ : ''
endfunction

function! LightLineMode() abort
  return  &ft == 'denite' ? 'Denite'
      \ : &ft == 'defx' ? 'Defx'
      \ : winwidth(0) > 70 ? lightline#mode()
      \ : ''
endfunction

function! LightLineFiletype() abort
  return &ft == 'defx' ? ''
      \ : winwidth(0) < 70 ? ''
      \ : strlen(&ft) != 0 ? &ft . ' ' . WebDevIconsGetFileTypeSymbol()
      \ : 'no ft'
endfunction

function! LightLineFileformat() abort
  return winwidth(0) < 70 ? ''
      \ : &fileformat . ' ' . WebDevIconsGetFileFormatSymbol()
endfunction

function! LightLineFileencoding() abort
  return winwidth(0) < 70 ? ''
      \ : strlen(&fenc) ? &fenc
      \ : &enc
endfunction
