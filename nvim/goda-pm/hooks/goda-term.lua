-- lua_add {{{
local function goda_term()
    -- toggle
    if vim.fn.win_id2win(vim.g.goda_term_ui_last_winid) == 0 then
        vim.fn["goda_term#start"]()
    else
        vim.api.nvim_win_close(vim.g.goda_term_ui_last_winid, true)
    end
end
vim.api.nvim_create_user_command("GodaTerm", goda_term, {})
vim.keymap.set("n", "<Leader>p", "<Cmd>GodaTerm<CR>")
-- }}}

-- lua_goda-term-terminal {{{
vim.opt_local.winfixheight = true
vim.keymap.set("n", "<CR>", "<Cmd>call goda_term#ui#do_action('executeLine')<CR>", { buffer = true })
-- }}}
