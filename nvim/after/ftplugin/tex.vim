" https://trap.jp/post/396

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

vnoremap <silent><buffer> <F5> :QuickRun -mode v -type tmptex<CR>

autocmd BufWritePost,FileWritePost *.tex QuickRun tex
autocmd BufNewFile *.tex 0r g:vim_home.'/template/tex.tex'

