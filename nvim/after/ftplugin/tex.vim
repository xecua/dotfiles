" lexima options for TeX
call lexima#add_rule({'char': '(', 'at': '\\\%#', 'input_after': '\)'})
call lexima#add_rule({'char': '[', 'at':'\\\%#', 'input_after': '\]'})
call lexima#add_rule({'char': '`', 'at': '`\%#', 'input_after': ''''''})
call lexima#add_rule({'char': '`', 'at': '`\%#`', 'input': '<right>''''<left><left>'})

" auto compile on save
augroup TeXMyCnf
    au!
    au BufWritePre,FileWritePre *.tex :call utils#normalize_punctuation()
    au BufWritePost,FileWritePost *.tex QuickRun
augroup END

" disable conceal
let g:tex_conceal = ''

setl makeprg=latexmk
