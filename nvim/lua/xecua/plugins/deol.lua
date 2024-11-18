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

local buf = nil
local win = nil

vim.keymap.set("n", "<Leader>p", function()
    -- darken background
    if buf == nil then
        buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
        win = vim.api.nvim_open_win(buf, true, {
            relative = "editor",
            width = vim.o.columns,
            height = vim.o.lines,
            col = 0,
            row = 0,
            focusable = false,
            style = "minimal",
        })
        vim.api.nvim_set_option_value("winblend", 50, { scope = "local", win = win })
    else
        pcall(vim.api.nvim_win_close, win, true)
        win = nil
        buf = nil
    end

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
