-- lua_post_source {{{
require("tabnine").setup({
    accept_keymap = false,
    dismiss_keymap = false,
    codelens_enabled = false,
    exclude_filetypes = {
        "dap-repl",
        "markdown",
        "dapui_watches",
        "dapui_scopes",
        "dapui_console",
    },
})

-- copied from https://github.com/codota/tabnine-nvim/blob/master/lua/tabnine/auto_commands.lua#L24, which doesn't work because triggered by VimEnter/ColorScheme event
vim.api.nvim_set_hl(0, require("tabnine.consts").tabnine_hl_group, {
    fg = "#808080",
    ctermfg = 244,
})

vim.keymap.set("i", "<C-l>", function()
    if require("tabnine.keymaps").has_suggestion() then
        return require("tabnine.keymaps").accept_suggestion()
    else
        return "<C-l>"
    end
end, { expr = true })
-- }}}
