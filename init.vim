" ftpluginを利用する際は必要(init.vimはfiletypeに関係なく行う設定を記述しているため)
filetype plugin indent off
"マウス有効化
set mouse=a

" シンタックスハイライト
syntax enable
" カラーテーマ
colorscheme molokai
" set background=dark
" colorscheme solarized
" 端末での色数を256色に
set t_Co=256
set fileformats=unix,dos,mac
" 端末上でTrue Colorを使用
set termguicolors
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
" 読み込み時に試みるエンコーディング(左から順に試す)
set fileencodings=ucs-bombs,utf-8,euc-jp,cp932
" 全角文字をちゃんと表示する
set ambiwidth=double
" スワップファイルを作らない
set noswapfile
" バッファを隠す(?)
set hidden
" クリップボードとNeoVimの無名レジスタを一体化
set clipboard+=unnamedplus
" 行番号
set number
" 空白文字等、不可視な文字の可視化
set list
" listの設定(デフォルトのが良さげだったので削除)
" set listchars=tab:>-,
" インデントとか 見ての通り
set smartindent
set visualbell

" 見た目の行間移動
nnoremap j gj
nnoremap k gk

" タブ関連 見ての通り(?)
set expandtab
set tabstop=4
set shiftwidth=4

" 検索関連
set ignorecase " 大文字と小文字を区別しない
set smartcase " 混在しているときに限り区別
set wrapscan " 下まで行ったら上に戻る
nmap <Esc><Esc> :nohlsearch<CR><Esc> " Esc連打でハイライト解除

" 行頭行末間移動(カーソルキー限定)
set whichwrap=b,s,<,>,[,]

" Shift+Enterで上に、Shift+Ctrl+Enterで下に空行を追加(GUI用)
imap <S-CR> <End><CR>
imap <C-S-CR> <Up><End><CR>

nnoremap <S-CR> mzo<ESC>`z
nnoremap <C-S-CR> mzO<ESC>`z

" ペースト時のインデントのズレを防ぐ(https://qiita.com/kqt0k0/items/bcfa84c5f85276315954)
if &term =~ "xterm"
    let &t_SI .= "\e[?2004h"
    let &t_EI .= "\e[?2004l"
    let &pastetoggle = "\e[201~"

    function XTermPasteBegin(ret)
        set paste
        return a:ret
    endfunction
    inoremap <special> <expr> <Esc>[200~ XTermPasteBegin("")]
endif

" pythonのpath
let g:python_host_prog = '/usr/bin/python2'
let g:python3_host_prog = expand('~/.pyenv/versions/neovim/bin/python3')

" Ctrl+W -> n で新規タブ
nnoremap <C-w>n <Esc>:enew<Return>

" <-- dein.vim
let s:dein_dir = expand('~/.cache/dein')
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'

if &runtimepath !~# '/dein.vim'
  if !isdirectory(s:dein_repo_dir)
    execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
  endif
  " execute 'set runtimepath^=' . fnamemodify(s:dein_repo_dir, ':p')
  set runtimepath^=~/.cache/dein/repos/github.com/Shougo/dein.vim/
endif
if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir)

  let g:rc_dir    = expand('~/.vim/rc')
  let s:toml      = g:rc_dir . '/dein.toml'
  let s:lazy_toml = g:rc_dir . '/dein_lazy.toml'

  call dein#load_toml(s:toml,      {'lazy': 0})
  call dein#load_toml(s:lazy_toml, {'lazy': 1})
  call dein#load_toml('~/.vim/rc/python.toml',{'lazy':1})

  call dein#end()
  call dein#save_state()
endif

if dein#check_install()
  call dein#install()
endif

" --> 

" 起動時にdeopleteを有効化
let g:deoplete#enable_at_startup = 1

" lightline.vim
set showtabline=2  " 常にタブラインを表示
set noshowmode  " 現在のモードを表示しない(lightlineで表示するため)


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

" lightline-ale, a support plugin for connect lightline and ale
let g:lightline.component_expand = {
            \ 'linter_checking': 'lightline#ale#checking',
            \ 'linter_warnings': 'lightline#ale#warnings',
            \ 'linter_errors': 'lightline#ale#errors',
            \ 'linter_ok': 'lightline#ale#ok'
            \ }

let g:lightline.component_type = {
            \ 'linter_checking': 'left',
            \ 'linter_warnings': 'warning',
            \ 'linter_errors': 'error',
            \ 'linter_ok': 'left'
            \ }


" WSLのクリップボードと連動
nnoremap <silent> <Space>y :.w !win32yank.exe -i<CR><CR>
vnoremap <silent> <Space>y :w !win32yank.exe -i<CR><CR>
nnoremap <silent> <Space>p :r !win32yank.exe -o<CR>
vnoremap <silent> <Space>p :r !win32yank.exe -o<CR>

" NERTreeの常駐/隠しファイルの常駐
let NERDTreeShowHidden = 1
autocmd StdinReadPre * let s:std_in = 1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
map <C-n> :NERDTreeToggle<CR> "ショートカット

" vim-quickrun
let g:quickrun_config = {
    \ '_' : {
        \ 'runner' : 'vimproc',
        \ 'runner/vimproc/updatetime' : 40,
        \ 'outputter' : 'error',
        \ 'outputter/error/success' : 'buffer',
        \ 'outputter/error/error'   : 'quickfix',
        \ 'outputter/buffer/split' : ':botright 8sp',
        \ 'outputter/buffer/close_on_empty' : 1,
    \ }
\}

" 実行時に前回の表示内容をクローズ&保存してから実行
" let g:quickrun_no_default_key_mappings = 1
" nmap <Leader>r :cclose<CR>:write<CR>:QuickRun -mode n<CR>


" ALE:https://qiita.com/lighttiger2505/items/e0ada17634516c081ee7#ale
" エラー行に表示するマーク
" let g:ale_sign_error = '⨉'
" let g:ale_sign_warning = '⚠'
" エラー行にカーソルをあわせた際に表示されるメッセージフォーマット
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
" エラー表示の列を常時表示
let g:ale_sign_column_always = 1

" ファイルを開いたときにlint実行
let g:ale_lint_on_enter = 1
" ファイルを保存したときにlint実行
let g:ale_lint_on_save = 1
" 編集中のlintはしない
let g:ale_lint_on_text_changed = 'never'

" lint結果をロケーションリストとQuickFixには表示しない
let g:ale_set_loclist = 0
let g:ale_set_quickfix = 0
let g:ale_open_list = 0
let g:ale_keep_list_window_open = 0

" 有効にするlinter
let g:ale_linters = {
\   'python': ['flake8'],
\}

" ALE用プレフィックス
nmap [ale] <Nop>
map <C-k> [ale]
" エラー行にジャンプ
nmap <silent> [ale]<C-k> <Plug>(ale_previous)
nmap <silent> [ale]<C-j> <Plug>(ale_next)

let g:quickrun_config.cpp = {
            \ 'command' : 'g++',
            \ 'cmdopt' : '-std=c++11'
            \ }


" Vim markdown(tpope)
autocmd BufNewFile,BufReadPost *.md set filetype=markdown
let g:markdown_fenced_languages = ['html','python','bash=sh']

" TeX Settings
" https://trap.jp/posts/396
" reset augroup
augroup MyAutoCmd
    autocmd!
augroup END


" neosnippet keymapping
imap <C-k>     <Plug>(neosnippet_expand_or_jump)
smap <C-k>     <Plug>(neosnippet_expand_or_jump)
xmap <C-k>     <Plug>(neosnippet_expand_target)

"Tab補完の設定
imap <expr><tab> pumvisible() ? "\<C-n>" :
\ neosnippet#expandable_or_jumpable() ?
\    "\<Plug>(neosnippet_expand_or_jump)" : "\<tab>"
smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
\ "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"


" conceal markers
if has('conceal')
    set conceallevel=0 concealcursor=niv
endif

" lexima options for TeX
call lexima#add_rule({'char': '$', 'input_after': '$', 'filetype': 'tex'})
call lexima#add_rule({'char': '$', 'at': '\%#\$', 'leave': 1, 'filetype': 'tex'})
call lexima#add_rule({'char': '<BS>', 'at': '\$\%#\$', 'delete': 1, 'filetype': 'tex'})

" VimTeX
let g:vimtex_compiler_latexmk_engines = { '_' : '-pdfdvi' }

" " Quickrun option for TeX
 let g:quickrun_config['tex'] = {
 \   'command' : 'latexmk',
 \   'outputter' : 'error',
 \   'outputter/error/success' : 'null',
 \   'outputter/error/error' : 'quickfix',
 \   'srcfile' : expand("%"),
 \   'cmpopt' : '-pdfdvi',
 \   'hook/sweep/files' : [
 \                        '%a/tmptex.latex',
 \                        '%a/tmptex.out',
 \                        '%a/tmptex.fdb_latexmk',
 \                        '%a/tmptex.log',
 \                        '%a/tmptex.aux',
 \                        '%a/tmptex.dvi'
 \                        ],
 \}
"  not in use?
"  \   'hook/eval/template' : '\documentclass{jsarticle}'
"  \                         .'\usepackage[dvipdfmx]{graphicx, hyperref}'
"  \                         .'\usepackage{comment}'
"  \                         .'\usepackage{float}'
"  \                         .'\usepackage{amsmath,amssymb,amsthm,ascmac,mathrsfs}'
"  \                         .'\allowdisplaybreaks[1]'
"  \                         .'\theoremstyle{definition}'
"  \                         .'\renewcommand{\thesection}{\arabic{section}}'
"  \                         .'\renewcommand{\thesubsection}{\alph{subsection}}'
"  \                         .'\newtheorem{theorem}{定理}'
"  \                         .'\newtheorem*{theorem*}{定理}'
"  \                         .'\newtheorem{definition}[theorem]{定義}'
"  \                         .'\newtheorem*{definition*}{定義}'
"  \                         .'\renewcommand\vector[1]{\mbox{\boldmath{\$#1\$}}}'
"  \                         .'\begin{document}'
"  \                         .'%s'
"  \                         .'\begin{thebibliography}{9}'
"  \                         .'\end{thebibliography}'
"  \                         .'\end{document}',
"  \
" 
vnoremap <silent><buffer> <F5> :QuickRun -mode v -type tmptex<CR>

" QuickRun and view compile result quickly (but don't preview pdf file)
nnoremap <silent><F5> :QuickRun<CR>

autocmd BufWritePost,FileWritePost *.tex QuickRun tex
autocmd BufNewFile *.tex 0r ~/.vim/template/tex.txt

" 最初にfiletype plugin indent offをしていた場合はこれで読み込みを行う
filetype plugin indent on

