" lexima options for TeX
call lexima#add_rule({'char': '$', 'input_after': '$', 'filetype': 'tex'})
call lexima#add_rule({'char': '$', 'at': '\%#\$', 'leave': 1, 'filetype': 'tex'})
call lexima#add_rule({'char': '<BS>', 'at': '\$\%#\$', 'delete': 1, 'filetype': 'tex'})

" VimTeX
let g:vimtex_compiler_latexmk_engines = { '_' : '-pdfdvi' }

" auto compile on save
autocmd BufWritePost,FileWritePost *.tex QuickRun

" expand template on new file
autocmd BufNewFile *.tex 0r g:vim_home.'/template/tex.tex'

