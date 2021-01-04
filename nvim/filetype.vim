augroup filetypedetect
  au! BufNewFile,BufRead */git/config.local setf gitconfig
  au! BufNewFile,BufRead .gitignore setf gitignore
  au! BufNewFile,BufRead *.swift setf swift
  au! BufNewFile,BufRead *.hx setf haxe
  au! BufNewFile,BufRead */nvim/template/* setf vim
augroup END
