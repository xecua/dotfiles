filetype plugin indent off
"マウス有効化
set mouse=a

" カラーテーマ
colorscheme molokai
" set background=dark
" colorscheme solarized
" 改行コードを指定
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
" closeしたバッファを(実際にはcloseせず)hiddenにする
set hidden
" クリップボードとNeovimの無名レジスタを一体化
set clipboard+=unnamedplus
" 行番号
set number
" 空白文字等、不可視な文字の可視化
set list
set listchars=tab:>-,space:*,nbsp:+
" インデントとか 見ての通り
set smartindent
set visualbell
" ヘルプの日本語化
set helplang=ja,en
" アイコン表示用の幅を確保
" set signcolumn=yes

" 見た目通りの移動
nnoremap j gj
nnoremap k gk

" タブ関連
set expandtab " スペースを使う
set tabstop=4 " 幅4
set shiftwidth=4 " 幅4

" 検索関連
" 大文字と小文字を区別しない
set ignorecase
" 混在しているときに限り区別
set smartcase
" 下まで行ったら上に戻る
set wrapscan
" Esc連打でハイライト解除
nmap <Esc><Esc> :nohlsearch<CR><Esc>

" 行頭行末間移動(backspace, space, カーソルキー)
set whichwrap=b,s,<,>,[,]

" pythonのpath
let g:python_host_prog = '/usr/local/bin/python2'
let g:python3_host_prog = '/usr/local/bin/python3'

" Ctrl+W -> n で新規タブ
nnoremap <C-w>n <Esc>:enew<Return>

" 常にタブラインを表示
set showtabline=2
" 現在のモードを表示しない
set noshowmode

" set all file whose extension is '.tex' as LaTeX file
let g:tex_flavor = 'latex'

" 各設定で利用する変数
let g:vim_home = $XDG_CONFIG_HOME.'/nvim'
let g:rc_dir = $XDG_CONFIG_HOME.'/nvim/rc'

set runtimepath+=$XDG_CONFIG_HOME/nvim

augroup MyFiletypeDetect
    autocmd!
    autocmd BufNewFile,BufRead *.nvim set filetype=vim
augroup END

" 各種プラグインの設定ファイルを読み込む
runtime! conf/*.vim
runtime! conf/*.nvim

filetype plugin indent on

