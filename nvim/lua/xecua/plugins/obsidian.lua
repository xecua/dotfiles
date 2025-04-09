-- lua_source {{{
if require("xecua.utils").get_local_config().obsidian_dir == vim.fn.getcwd() then
    require("obsidian").setup({
        dir = require("xecua.utils").get_local_config().obsidian_dir,
        templates = {
            subdir = "templates",
        },
        daily_notes = { folder = "dailynotes", date_format = "%Y-%m-%d", template = "dailynote.md" },
        disable_frontmatter = true,
        follow_url_func = function(url)
            vim.ui.open(url)
        end,
        ui = { enable = false },
    })

    vim.keymap.set("n", "<Leader>bt", "<Cmd>ObsidianToday<CR>")
    vim.keymap.set("n", "<Leader>bm", "<Cmd>ObsidianTomorrow<CR>")
    vim.keymap.set("n", "<Leader>by", "<Cmd>ObsidianYesterday<CR>")
    vim.keymap.set("n", "<Leader>bs", "<Cmd>ObsidianQuickSwitch<CR>")
    vim.keymap.set("n", "<Leader>bo", "<Cmd>ObsidianOpen<CR>")
end
-- }}}
