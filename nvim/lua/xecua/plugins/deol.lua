-- lua_add {{{
local deol_group_id = vim.api.nvim_create_augroup("DeolMyCnf", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
    group = deol_group_id,
    pattern = "deol",
    callback = function()
        vim.keymap.set("n", "a", "<Plug>(deol_start_append)", { buffer = true })
        vim.keymap.set("n", "i", "<Plug>(deol_start_insert)", { buffer = true })
        vim.keymap.set("n", "A", "<Plug>(deol_start_append_last)", { buffer = true })
        vim.keymap.set("n", "I", "<Plug>(deol_start_insert_first)", { buffer = true })
    end,
})

vim.keymap.set("n", "<Leader>p", function()
    vim.fn["deol#start"]({
        wincol = vim.o.columns / 18,
        winwidth = vim.o.columns * 8 / 9,
        winrow = vim.o.lines / 18,
        winheight = math.floor(vim.o.lines * 8 / 9),
        toggle = true,
        split = "floating",
        floating_border = "single",
    })
end)
-- }}}
