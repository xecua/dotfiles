augroup filetypedetect
  au! BufNewFile,BufRead ~/.config/git/globalconfig setf gitconfig
  au! BufNewFile,BufRead .gitignore setf gitignore
  au! BufNewFile,BufRead *.swift setf swift
augroup END
