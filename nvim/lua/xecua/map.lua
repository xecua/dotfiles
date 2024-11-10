-- keymaps
vim.keymap.set("n", "<Esc><Esc>", "<Cmd>nohlsearch<CR>")
vim.keymap.set("n", "<C-[><C-[>", "<Cmd>nohlsearch<CR>")
vim.keymap.set("n", "<Leader>x", "<Cmd>silent cclose<CR><Bar><Cmd>silent lclose<CR>")
vim.keymap.set("n", "<Leader>tq", "<Cmd>lua vim.diagnostic.setqflist()<CR>")
vim.keymap.set("n", "<Leader>tl", "<Cmd>lua vim.diagnostic.setloclist()<CR>")
-- vimgrep under cursor in current file
vim.keymap.set("n", "<Leader>v", ":<C-u>lv /<C-r><C-w>/j %<CR>")
-- Always enable verymagic (a.k.a. ERE). see :h \v
vim.keymap.set("n", "/", "/\\v")
vim.keymap.set("n", "?", "?\\v")
vim.keymap.set("v", "/", "<Esc>/\\%V\\v") -- \%V: previously selected range
vim.keymap.set("v", "?", "<Esc>?\\%V\\v") -- \%V: previously selected range
vim.keymap.set({ "n", "v" }, ":s/", ":s/\\v")
vim.keymap.set("n", ":%s/", ":%s/\\v")
vim.keymap.set("n", "<F3>", "<Cmd>set cursorline!<Bar>set cursorcolumn!<CR>")
vim.keymap.set("n", "gf", "<Cmd>e <cfile><CR>")

vim.keymap.set("t", "<C-]>", [[<C-\><C-n>]])

-- full-width parentheses
vim.keymap.set("o", "ifP", "<Cmd>normal! T（vt）<CR>", { desc = "Inner Full-width Parenthesis" })
vim.keymap.set("v", "ifP", "<Cmd>normal! T（ot）<CR>", { desc = "Inner Full-width Parenthesis" })
vim.keymap.set("o", "afP", "<Cmd>normal! F（vf）<CR>", { desc = "Outer Full-width Parenthesis" })
vim.keymap.set("v", "afP", "<Cmd>normal! F（of）<CR>", { desc = "Outer Full-width Parenthesis" })
vim.keymap.set("o", "ifB", "<Cmd>normal! T「vt」<CR>", { desc = "Inner Full-width Hooked Bracket" })
vim.keymap.set("v", "ifB", "<Cmd>normal! T「ot」<CR>", { desc = "Inner Full-width Hooked Bracket" })
vim.keymap.set("o", "afB", "<Cmd>normal! F「vf」<CR>", { desc = "Outer Full-width Hooked Bracket" })
vim.keymap.set("v", "afB", "<Cmd>normal! F「of」<CR>", { desc = "Outer Full-width Hooked Bracket" })
vim.keymap.set("o", "ifD", "<Cmd>normal! T『vt』<CR>", { desc = "Inner Full-width Double Hooked Bracket" })
vim.keymap.set("v", "ifD", "<Cmd>normal! T『ot』<CR>", { desc = "Inner Full-width Double Hooked Bracket" })
vim.keymap.set("o", "afD", "<Cmd>normal! F『vf』<CR>", { desc = "Outer Full-width Double Hooked Bracket" })
vim.keymap.set("v", "afD", "<Cmd>normal! F『of』<CR>", { desc = "Outer Full-width Double Hooked Bracket" })
