-- lua_add {{{
local function ddt_term()
    -- toggle
    if vim.fn.win_id2win(vim.g.ddt_ui_last_winid) == 0 then
        vim.fn["ddt#start"]()
    else
        vim.api.nvim_win_close(vim.g.ddt_ui_last_winid, true)
    end
end
vim.api.nvim_create_user_command("DdtTerm", ddt_term, {})
vim.keymap.set("n", "<Leader>p", "<Cmd>DdtTerm<CR>")
-- }}}

-- lua_source {{{
local is_darwin = require("xecua.utils").get_os_string() == "Darwin"

vim.fn["ddt#custom#patch_global"]({
    ui = "terminal",
    uiParams = {
        terminal = {
            -- toggle = true,
            split = "horizontal",
            command = is_darwin and "zsh" or "bash",
            startInsert = true,
            winHeight = 10,
        },
    },
})
-- }}}

-- lua_ddt-terminal {{{
vim.opt_local.winfixheight = true
vim.keymap.set("n", "<CR>", "<Cmd>call ddt#ui#do_action('executeLine')<CR>", { buffer = true })
-- }}}
