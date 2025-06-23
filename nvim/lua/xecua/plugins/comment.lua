-- lua_add {{{
vim.keymap.set("n", "<C-_><C-_>", "<Plug>(comment_toggle_linewise_current)")
vim.keymap.set("v", "<C-_><C-_>", "<Plug>(comment_toggle_linewise_visual)")
vim.keymap.set("v", "<C-_>b", "<Plug>(comment_toggle_blockwise_visual)")
-- }}}

-- lua_source {{{
require("Comment").setup({
    ignore = "^$",
    mappings = {
        basic = false,
        extra = false,
    },
    pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
})
-- }}}
