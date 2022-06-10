filetype plugin indent off

" プラットフォームで異なる設定をする(https://vi.stackexchange.com/a/2577)
if !exists("g:os")
  if has("win64") || has("win32") || has("win16")
    let g:os = "Windows"
  else
    let g:os = substitute(system('uname'), '\n', '', '')
    if g:os == "Linux"
      let lines = readfile("/proc/version")
      if lines[0] =~ "Microsoft"
        let g:os = "WSL"
      endif
    endif
  endif
endif

if g:os == 'Linux'
  if exists('g:neovide')
    set guifont=Cica:h12
  else
    set guifont=Cica\ 12
  endif
else
  set guifont=Cica:h16
endif

" <Leader> := <Space>
let mapleader="\<Space>"
"マウス有効化
set mouse=a
" allow change title
set title
" 改行コードを指定
set fileformats=unix,dos,mac
" 端末上でTrue Colorを使用
set termguicolors
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
" 読み込み時に試みるエンコーディング(左から順に試す)
set fileencodings=ucs-bombs,utf-8,euc-jp,cp932
set noswapfile
set autoread
" closeしたバッファを(実際にはcloseせず)hiddenにする
set hidden
" クリップボードとNeovimの無名レジスタを一体化
set clipboard+=unnamedplus
set number
set list
set listchars=tab:>-,trail:*,nbsp:+
set smartindent
set visualbell
" ヘルプの日本語化
set helplang=ja,en
" アイコン表示用の幅を確保
" set signcolumn=yes
set updatetime=300

" タブ関連
set expandtab " tabstop個の連続したスペースをtabに変換しない
set softtabstop=-1 " <Tab>・<BS>での移動幅(-1 => shiftwidth)
set shiftwidth=0 " 改行・<</>>でのインデント量(0 => tabstop)
set tabstop=4 " tab文字の幅
let g:vim_indent_cont = 4 " 継続行のインデント量を固定

" 検索関連
set ignorecase
set smartcase
set wrapscan
nmap <Esc><Esc> :nohlsearch<CR><Esc>

" 行頭行末間移動(backspace, space, カーソルキー(normal/visual, insert/replace))
set whichwrap=b,s,<,>,[,]

" pythonのpath
if g:os == 'Darwin'
  let g:python_host_prog = ''
  let g:python3_host_prog = '/usr/local/bin/python3'
elseif g:os == 'Linux'
  let g:python_host_prog = ''
  let g:python3_host_prog = '/usr/bin/python'
else
  let g:python_host_prog = ''
  let g:python3_host_prog = ''
end

" close quickfix
nnoremap <Leader>x :cclose<CR>

" 常にタブラインを表示
set showtabline=2
" 現在のモードを表示しない
set noshowmode

" set all file whose extension is '.tex' as LaTeX file
let g:tex_flavor = "latex"

" 各設定で利用する変数
let g:vim_home = $XDG_CONFIG_HOME.'/nvim'

" undofile
set undofile
set undodir=$XDG_CACHE_HOME/nvim/undo

" back to Normal mode using Esc in Terminal mode
tnoremap <Esc> <C-\><C-n>

" see :h DiffOrig
command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis | wincmd p | diffthis

" enable embedded code highlight
let g:vimsyn_embed = 'l'
let g:markdown_fenced_languages = [
\ 'html',
\ 'python',
\ 'bash=sh',
\ 'js=javascript',
\ 'json=javascript',
\ 'c',
\ 'vim'
\]

" Resize without repeately pressing C-w
" https://zenn.dev/mattn/articles/83c2d4c7645faa
nmap <C-w>+ <C-w>+<SID>ws
nmap <C-w>- <C-w>-<SID>ws
nmap <C-w>> <C-w>><SID>ws
nmap <C-w>< <C-w><<SID>ws
nnoremap <script> <SID>ws+ <C-w>+<SID>ws
nnoremap <script> <SID>ws- <C-w>-<SID>ws
nnoremap <script> <SID>ws> <C-w>><SID>ws
nnoremap <script> <SID>ws< <C-w><<SID>ws
nmap <SID>ws <Nop>

if exists('g:vscode')
  " inside VSCode
  let g:startify_disable_at_vimenter = 1
else
  " https://twitter.com/otukaw/status/1367741425765412871
  set ambiwidth=double
endif
let g:startify_change_to_dir = 0

augroup Init
  au!
  " remove redundant lines at the end of file. see https://stackoverflow.com/a/7496112
  " and vim always add <EOL> to the end of file if not exist (see 'fixeol').
  au BufWritePre * :silent! %s#\($\n\s*\)\+\%$##
  au VimEnter * call s:load_local_vimrc()

  au BufNewFile,BufRead *.tsx,*.jsx setf typescriptreact
  au FileType c,cpp,fish,html,javascript,json,lua,rst,satysfi,typescript,typescriptreact,vim,vue,xml,yaml setl tabstop=2
  au FileType gitconfig,go setl noexpandtab

  " automatically open pdf as text in new buffer. requirement: pdftotext (included in poppler)
  " see https://qiita.com/u1and0/items/526d95d6991bc19003d2
  if executable('pdftotext')
    au BufRead *.pdf :enew  | file #.txt | 0read !pdftotext -layout -nopgbrk "#" -
  end
augroup END

" 各種プラグインの設定ファイルを読み込む
" <-- dein.vim
let s:dein_dir = $XDG_CACHE_HOME.'/dein'
let s:dein_repo_dir = s:dein_dir.'/repos/github.com/Shougo/dein.vim'

if &runtimepath !~# '/dein.vim'
  if !isdirectory(s:dein_repo_dir)
    execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
  endif
  execute 'set runtimepath^='.s:dein_repo_dir
endif
if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir)

  call dein#load_toml(g:vim_home.'/dein.toml', {'lazy': 0})
  call dein#load_toml(g:vim_home.'/dein_lazy.toml', {'lazy': 1})

  call dein#end()
  call dein#save_state()
endif

if dein#check_install()
  call dein#install()
endif
" -->

" other plugins' configuration
" common
runtime! conf/*.vim


nmap j <Plug>(accelerated_jk_gj)
nmap k <Plug>(accelerated_jk_gk)

nmap <Leader>j <Plug>(jumpcursor-jump)

if exists('g:vscode')
  filetype plugin on " indent not needed
else
  " nvim-lsp
  if has('nvim-0.5')
    " eclipse.jdt.ls https://github.com/williamboman/nvim-lsp-installer/blob/main/lua/nvim-lsp-installer/servers/jdtls/init.lua#L84
    let $WORKSPACE = $HOME."/Documents/eclipse-workspace/jdt.ls"
    lua require('lsp')
    lua require('treesitter')
  endif
  " plugin specific, but simple config
  colorscheme molokai
  let g:loaded_matchparen = 1 " disable default matchparen

  if g:os == 'Darwin'
    let g:previm_open_cmd = 'open -a Safari'
  elseif g:os == 'Linux'
    let g:previm_open_cmd = 'vivaldi-stable'
  end

  nnoremap <leader>u :UndotreeToggle<CR>

  let g:closetag_filetypes = 'html,xhtml,phtml,xml,jsx,tsx,javascript.jsx,typescript.tsx,javascriptreact,typescriptreact'
  let g:closetag_xhtml_filetypes = 'xhtml,jsx,tsx,javascript.jsx,typescript.tsx,javascriptreact,typescriptreact'

  let g:python_highlight_all = 1
  call tcomment#type#Define('satysfi', '%% %s')
  call tcomment#type#Define('glsl', '// %s')
  let g:copilot_filetypes = {
      \ 'tex': v:false,
      \ 'satysfi': v:false
      \ }
  " not expand by tab
  inoremap <silent><script><expr> <C-l> copilot#Accept()
  let g:copilot_no_tab_map = v:true

  call popup_preview#enable()
  call signature_help#enable()

  filetype plugin indent on
endif

" https://qiita.com/unosk/items/43989b61eff48e0665f3
function! s:load_local_vimrc()
  let files = findfile('.vim/vimrc', getcwd().';', -1)
  for i in reverse(filter(files, 'filereadable(v:val)'))
    source `=i`
  endfor
endfunction
