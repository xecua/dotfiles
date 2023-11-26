-- lua_add {{{
vim.g.tcomment_maps = false
vim.keymap.set({ 'n', 'i', 'v' }, '<C-_><C-_>', '<Plug>TComment_<c-_><c-_>')
vim.keymap.set({ 'n', 'i', 'v' }, '<C-_>b', '<Plug>TComment_<c-_>b')
-- }}}

-- lua_post_source {{{
vim.fn['tcomment#type#Define']('satysfi', '%% %s')
vim.fn['tcomment#type#Define']('glsl', '// %s')
vim.fn['tcomment#type#Define']('kotlin', '// %s')
vim.fn['tcomment#type#Define']('hjson', '# %s')
vim.fn['tcomment#type#Define']('hjson_block', '/* %s */')
vim.fn['tcomment#type#Define']('tex_block', [[\begin{comment}%s\end{comment}]])
-- }}}
