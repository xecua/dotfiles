" ftpluginを利用する際は必要(init.vimはfiletypeに関係なく行う設定を記述しているため)
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
" バッファを隠す(?)
set hidden
" クリップボードとNeoVimの無名レジスタを一体化
set clipboard+=unnamedplus
" 行番号
set number
" 空白文字等、不可視な文字の可視化
set list
set listchars=tab:>-,trail:*,nbsp:+
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

" WSLのクリップボードと連動
nnoremap <silent> <Space>y :.w !win32yank.exe -i<CR><CR>
vnoremap <silent> <Space>y :w !win32yank.exe -i<CR><CR>
nnoremap <silent> <Space>p :r !win32yank.exe -o<CR>
vnoremap <silent> <Space>p :r !win32yank.exe -o<CR>

" 常にタブラインを表示
set showtabline=2
" 現在のモードを表示しない(lightlineで表示するため)
set noshowmode

" Vim markdown(tpope) ぷらぎんでもないのでココに。
let g:markdown_fenced_languages = [
\ 'html',
\ 'python',
\ 'bash=sh',
\ 'js=javascript',
\ 'json=javascript',
\ 'c',
\ 'vim'
\]

" 各設定で利用する変数
let g:vim_home = $XDG_CONFIG_HOME.'/nvim'
let g:rc_dir = $XDG_CONFIG_HOME.'/nvim/rc'

set runtimepath+=$XDG_CONFIG_HOME/nvim

" 各種プラグインの設定ファイルを読み込む
runtime! conf/*.vim

" 最初にfiletype plugin indent offをしていた場合はこれで読み込みを行う
filetype plugin indent on

