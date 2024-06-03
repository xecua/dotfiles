-- keymaps
vim.keymap.set('n', '<Esc><Esc>', '<Cmd>nohlsearch<CR>')
vim.keymap.set('n', '<C-[><C-[>', '<Cmd>nohlsearch<CR>')
vim.keymap.set('n', '<Leader>x', '<Cmd>silent cclose<CR><Bar><Cmd>silent lclose<CR>')
vim.keymap.set('n', '<Leader>tq', '<Cmd>lua vim.diagnostic.setqflist()<CR>')
vim.keymap.set('n', '<Leader>tl', '<Cmd>lua vim.diagnostic.setloclist()<CR>')
-- vimgrep under cursor in current file
vim.keymap.set('n', '<Leader>v', ':<C-u>lv /<C-r><C-w>/j %<CR>')
-- Always enable verymagic (a.k.a. ERE). see :h \v
vim.keymap.set({ 'n', 'v' }, '/', '/\\v')
vim.keymap.set({ 'n', 'v' }, '?', '?\\v')
vim.keymap.set({ 'n', 'v' }, ':s/', ':s/\\v')
vim.keymap.set({ 'n', 'v' }, ':%s/', ':%s/\\v')

vim.keymap.set('t', '<C-]>', [[<C-\><C-n>]])
