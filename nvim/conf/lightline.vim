let g:lightline = {
            \ 'colorscheme' : 'jellybeans'
            \ }
let g:lightline.active = {
            \   'left': [ ['mode', 'paste'],
            \             ['fugitive', 'readonly', 'filename', 'modified'] ],
            \   'right': [ [ 'lineinfo' ],
            \              [ 'percent', 'ale' ],
            \              [ 'fileformat', 'fileencoding', 'filetype' ] ]
            \ }
let g:lightline.tabline = {
            \ 'left': [ [ 'tabs' ] ],
            \ 'right': [ [ 'close', 'time' ] ]
            \ }
let g:lightline.component = {
            \   'readonly': '%{&readonly ? "⭤" : ""}',
            \ }

let g:lightline.component_function = {
            \   'modified': 'LightLineModified',
            \   'readonly': 'LightLineReadonly',
            \   'fugitive': 'LightLineFugitive',
            \   'filename': 'LightLineFilename',
            \   'fileformat': 'LightLineFileformat',
            \   'filetype': 'LightLineFiletype',
            \   'fileencoding': 'LightLineFileencoding',
            \   'mode': 'LightLineMode',
            \   'time': 'LightLineTime',
            \ }

" temporarily unuse
" 'ale': 'LightLineAle',
" 'battery': 'LightLineBattery',

let g:lightline.separator = {
            \   'left': "\ue0b0", 'right': "\ue0b2"
            \ }

let g:lightline.subseparator = {
            \ 'left': "\ue0b1", 'right': '\ue0b3'
            \ }

function! LightLineModified()
    return &ft =~ 'help\|nerdtree' ? '' : &modified ? '+' : &modifiable ? '' : '-'
endfunction

function! LightLineReadonly()
    return &ft !~? 'help\|nerdtree' && &readonly ? 'x' : ''
endfunction

function! LightLineFilename()
    return ('' != LightLineReadonly() ? LightLineReadonly() . ' ' : '') .
                \ (&ft == 'denite' ? denite#get_status_sources() :
                \ (&ft == 'nerdtree' ? expand('%:~:h') :
                \ '' != expand('%:t') ? expand('%:~:.:h') . '/'. expand('%:t') : '[No Name]'))
endfunction

function! LightLineFiletype()
    return winwidth(0) > 70 ? (strlen(&filetype) ? &filetype . ' ' . WebDevIconsGetFileTypeSymbol()[0:2] : 'no ft') : ''
endfunction

function! LightLineFileformat()
    return winwidth(0) > 70 ? (&fileformat . ' ' . WebDevIconsGetFileFormatSymbol()) : ''
endfunction

function! LightLineFileencoding()
    return  &ft == 'nerdtree' ? '' :
                \ winwidth(0) > 70 ? (strlen(&fenc) ? &fenc : &enc) : ''
endfunction

function! LightLineMode()
    return  &ft == 'denite' ? 'Denite' :
                \ &ft == 'nerdtree' ? 'NERDTree' :
                \ winwidth(0) > 60 ? lightline#mode() : ''
endfunction

augroup LightLineOnALE
    autocmd!
    autocmd User ALELint call lightline#update()
augroup END

function! LightLineAle()
    return exists('*ALEGetStatusLine') ? ALEGetStatusLine() : 'ALE not found.'
endfunction

function! LightLineFugitive()
    try
        if &ft !~? 'vimfiler\|gundo\|vaffle' && exists('*fugitive#head')
            let _ = fugitive#head()
            return strlen(_) ? '⭠ '._ : ''
        endif
    catch
    endtry
    return ''
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
