-- lua_source {{{
local default_vault = require("xecua.utils").get_local_config().obsidian_dir

require("obsidian").setup({
    templates = {
        subdir = "templates",
    },
    daily_notes = { folder = "dailynotes", date_format = "%Y-%m-%d", template = "dailynote.md" },
    disable_frontmatter = true,
    follow_url_func = function(url)
        vim.ui.open(url)
    end,
    ui = { enable = false },
    workspaces = {
        {
            name = vim.fs.basename(default_vault),
            path = default_vault,
        },
        {
            name = "no-vault",
            path = function()
                return assert(vim.fn.getcwd())
            end,
            overrides = {
                notes_subdir = vim.NIL,
                templates = { folder = vim.NIL },
                daily_notes = { folder = vim.NIL, date_format = vim.NIL, template = vim.NIL },
            },
        },
    },
})

vim.keymap.set("n", "<Leader>bt", "<Cmd>ObsidianToday<CR>")
vim.keymap.set("n", "<Leader>bm", "<Cmd>ObsidianTomorrow<CR>")
vim.keymap.set("n", "<Leader>by", "<Cmd>ObsidianYesterday<CR>")
vim.keymap.set("n", "<Leader>bs", "<Cmd>ObsidianQuickSwitch<CR>")
vim.keymap.set("n", "<Leader>bo", "<Cmd>ObsidianOpen<CR>")
-- }}}
