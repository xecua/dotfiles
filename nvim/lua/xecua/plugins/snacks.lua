-- lua_add {{{
vim.api.nvim_create_user_command("SnacksLazygit", 'lua require("snacs").lazygit()', {})
vim.api.nvim_create_user_command("SnacksBufDelete", 'lua require("snacks").bufdelete()', {})
vim.api.nvim_create_user_command("SnacksGitBrowse", 'lua require("snacks").gitbrowse()', {})
vim.keymap.set("n", "<Leader>gg", '<Cmd>lua require("snacks").lazygit()<CR>')
-- }}}

-- lua_post_source {{{
require("snacks").setup({
    notifier = { enabled = false },
    words = { enabled = false },
    win = { wo = { winhighlight = "" } },
    -- 色が変……
    lazygit = {
        configure = false,
        config = { os = { editPreset = "nvim-remote" }, gui = { nerdFontsVersion = "3" } },
    },
})
-- }}}
