-- lua_add {{{
vim.g["fern#renderer"] = "nvim-web-devicons"
vim.g["fern#disable_auto_buffer_delete"] = true
vim.g["fern#disable_auto_buffer_rename"] = true

vim.keymap.set("n", "<C-n>", "<Cmd>Fern . -reveal=%:p -drawer -toggle<CR>")
-- }}}

-- lua_fern {{{
vim.opt_local.list = false
vim.opt_local.wrap = false

vim.fn["glyph_palette#apply"]()

vim.keymap.set("n", "<LeftRelease>", function()
    return vim.fn["fern#smart#leaf"](
        "<Plug>(fern-action-open)",
        "<Plug>(fern-action-expand)",
        "<Plug>(fern-action-collapse)"
    )
end, { buffer = true, expr = true }) -- 選択は<LeftMouse>でやってる
vim.keymap.set("n", "e", "<Plug>(fern-action-open:select)", { buffer = true })
vim.keymap.set("n", "s", "<Plug>(fern-action-open:split)", { nowait = true, buffer = true })
vim.keymap.set("n", "v", "<Plug>(fern-action-open:vsplit)", { buffer = true })
-- }}}
