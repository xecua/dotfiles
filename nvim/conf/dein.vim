let s:dein_dir = $XDG_CACHE_HOME.'/dein'
let s:dein_repo_dir = s:dein_dir.'/repos/github.com/Shougo/dein.vim'

if &runtimepath !~# '/dein.vim'
  if !isdirectory(s:dein_repo_dir)
    execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
  endif
  " execute 'set runtimepath^=' . fnamemodify(s:dein_repo_dir, ':p')
  set runtimepath^=$XDG_CACHE_HOME/dein/repos/github.com/Shougo/dein.vim/
endif
if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir)

  let s:toml      = g:rc_dir . '/dein.toml'
  let s:lazy_toml = g:rc_dir . '/dein_lazy.toml'

  call dein#load_toml(s:toml,      {'lazy': 0})
  call dein#load_toml(s:lazy_toml, {'lazy': 1})

  call dein#end()
  call dein#save_state()
endif

if dein#check_install()
  call dein#install()
endif

" remove cached plugins(run :call dein#recache_runtimepath() to complete)
" call map(dein#check_clean(), "delete(v:val, 'rf')")
