-- keymaps
vim.keymap.set('n', '<Esc><Esc>', '<Cmd>nohlsearch<CR>')
vim.keymap.set('n', '<C-[><C-[>', '<Cmd>nohlsearch<CR>')
vim.keymap.set('n', '<Leader>x', '<Cmd>cclose<CR>')
-- Always enable verymagic (a.k.a. ERE). see :h \v
vim.keymap.set({ 'n', 'v' }, '/', '/\\v')
vim.keymap.set({ 'n', 'v' }, '?', '?\\v')
vim.keymap.set({ 'n', 'v' }, ':s/', ':s/\\v')
vim.keymap.set({ 'n', 'v' }, ':%s/', ':%s/\\v')

vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]])
