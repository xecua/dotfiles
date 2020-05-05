let g:lightline = {
  \ 'colorscheme': 'wombat',
  \ 'active': {
  \   'left': [ ['mode', 'paste'],
  \             [ 'gitbranch', 'readonly', 'filename', 'modified'] ],
  \   'right': [ [ 'lineinfo' ],
  \              [ 'percent' ],
  \              [ 'fileformat', 'fileencoding', 'filetype' ] ]
  \ },
  \ 'inactive': {
  \   'left': [ [ 'filename' ] ],
  \   'right': [ [ 'lineinfo' ], [ 'percent' ] ]
  \ },
  \ 'tabline': {
  \   'left': [ [ 'tabs' ] ],
  \   'right': [ [ 'close' ], [ 'battery', 'time' ] ]
  \ },
  \ 'component': {
  \   'readonly': '%{&readonly ? "⭤" : ""}',
  \ },
  \ 'component_function': {
  \   'modified': 'LightLineModified',
  \   'readonly': 'LightLineReadonly',
  \   'fugitive': 'LightLineFugitive',
  \   'gitbranch': 'FugitiveHead',
  \   'filename': 'LightLineFilename',
  \   'fileformat': 'LightLineFileformat',
  \   'filetype': 'LightLineFiletype',
  \   'fileencoding': 'LightLineFileencoding',
  \   'mode': 'LightLineMode',
  \   'battery': 'LightLineBattery',
  \   'time': 'LightLineTime',
  \ },
  \ 'separator': { 'left': "\ue0b0", 'right': "\ue0b2" },
  \ 'subseparator': { 'left': "\ue0b1", 'right': "\ue0b3" },
  \ }

" if the buffer is help/nerdtree, not display(ref> :help /bar)
" "help\|nerdtree"(double quoted) is 'help|nerdtree', which won't match in expected buffers
function! LightLineModified()
  return &ft =~ 'help\|defx' ? '' : &modified ? '+' : &modifiable ? '' : '-'
endfunction

function! LightLineReadonly()
  return (&ft !~ 'help\|defx' && &readonly) ? '[readonly]' : ''
endfunction

function! LightLineFilename()
  return (&ft == 'denite' ? denite#get_status_sources() :
    \  (&ft == 'defx' ? expand('%:~:h') :
    \  (expand('%') != '' ? expand('%:~'): '[No Name]')))
endfunction

function! LightLineFiletype()
  return &ft == 'defx' ? '' :
    \   winwidth(0) > 70 ? (strlen(&filetype) ? &filetype . ' ' . WebDevIconsGetFileTypeSymbol() : 'no ft') : ''
endfunction

function! LightLineFileformat()
  return winwidth(0) > 70 ? (&fileformat . ' ' . WebDevIconsGetFileFormatSymbol()) : ''
endfunction

function! LightLineFileencoding()
  return winwidth(0) > 70 ? (strlen(&fenc) ? &fenc : &enc) : ''
endfunction

function! LightLineMode()
  return  &ft == 'denite' ? 'Denite' :
    \ &ft == 'defx' ? 'Defx' :
    \ winwidth(0) > 60 ? lightline#mode() : ''
endfunction

function! LightLineBattery()
  let battery = str2nr(system("pmset -g ps | tail -n 1 | awk '{print $3}' | sed 's/;//'")[:-3], 10)
  let batteryIcon = battery >= 80 ? ' ' :
                  \ battery >= 60 ? ' ' :
                  \ battery >= 40 ? ' ' :
                  \ battery >= 20 ? ' ' :
                  \ battery >= 0  ? ' ' : ''
  return printf('%d%% %s', battery, batteryIcon)
endfunction

function! LightLineTime()
  return system('date +"%H:%M"')[:-2]
endfunction
