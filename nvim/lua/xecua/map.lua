-- keymaps
vim.keymap.set("n", "<Esc><Esc>", "<Cmd>nohlsearch<CR>")
vim.keymap.set("n", "<C-[><C-[>", "<Cmd>nohlsearch<CR>")
vim.keymap.set("n", "<Leader>x", "<Cmd>silent cclose<CR><Bar><Cmd>silent lclose<CR>")
vim.keymap.set("n", "<Leader>tq", "<Cmd>lua vim.diagnostic.setqflist()<CR>")
vim.keymap.set("n", "<Leader>tl", "<Cmd>lua vim.diagnostic.setloclist()<CR>")
vim.keymap.set("n", "zK", "<Cmd>normal! zszH<CR>")
vim.keymap.set("n", "<C-w>o", "<nop>")
vim.keymap.set("n", "<C-w><C-o>", "<nop>")
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

-- _default.lua
vim.keymap.del("n", "grn")
vim.keymap.del({ "n", "x" }, "gra")
vim.keymap.del("n", "grr")
vim.keymap.del("n", "gri")
vim.keymap.del("n", "gO")

vim.keymap.set("n", "gf", function()
    local cfile = vim.fs.normalize(vim.fn.expand("<cfile>"))
    if string.match(cfile, "^/") then
        vim.cmd.edit(cfile)
        return
    end
    local file_dir = vim.fn.expand("%:h")
    vim.cmd.edit(vim.fs.normalize(vim.fs.joinpath(file_dir, cfile)))
end)
vim.keymap.set("n", "<Leader>h", function()
    -- Show hlgroup under cursor
    -- https://stackoverflow.com/questions/9464844/how-to-get-group-name-of-highlighting-under-cursor-in-vim/37040415#37040415
    local pos = vim.fn.getpos(".")
    local symbol_id = vim.fn.synID(pos[2], pos[3], 1)
    vim.print(vim.fn.synIDattr(symbol_id, "name") .. " -> " .. vim.fn.synIDattr(vim.fn.synIDtrans(symbol_id), "name"))
end)

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
