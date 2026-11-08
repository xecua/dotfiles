-- lua_add {{{
local augroup = vim.api.nvim_create_augroup("GodaSkkConfig", { clear = true })

-- 辞書のパスはマシンごとに違うので環境変数でGoに渡す
vim.env.GODA_SKK_DICTIONARIES = vim.json.encode(require("xecua.utils").get_local_config().skk_dictionaries)

vim.keymap.set({ "i", "c", "l", "t" }, "<C-j>", "<Plug>(goda-skk-enable)")

vim.api.nvim_create_autocmd("User", {
    pattern = "goda-skk-enable-pre",
    group = augroup,
    callback = function()
        if vim.b.prev_buffer_skk_config ~= nil then
            return
        end
        vim.b.prev_buffer_skk_config = vim.fn["goda_cmp#get_buffer"]()
        vim.fn["goda_cmp#patch_buffer"]({
            sources = { "skk", "skkokuri" },
        })
    end,
})
vim.api.nvim_create_autocmd("User", {
    pattern = "goda-skk-disable-post",
    group = augroup,
    callback = function()
        if vim.b.prev_buffer_skk_config ~= nil then
            vim.fn["goda_cmp#set_buffer"](vim.b.prev_buffer_skk_config)
            vim.b.prev_buffer_skk_config = nil
        end
    end,
})
-- }}}

-- lua_source {{{
vim.api.nvim_set_hl(0, "GodaSkkHenkan", { underline = true })
vim.api.nvim_set_hl(0, "GodaSkkHenkanSelect", { underline = true, reverse = true })

vim.fn["goda_skk#state_popup#config"]({
    labels = {
        input = { hira = "あ", kata = "ア", hankata = "ｱ", zenkaku = "Ａ" },
        ["input:okurinasi"] = { hira = "あ", kata = "ア", hankata = "ｱ", abbrev = "a" },
        ["input:okuriari"] = { hira = "あ", kata = "ア", hankata = "ｱ" },
        henkan = { hira = "あ", kata = "ア", hankata = "ｱ", abbrev = "a" },
    },
    opts = { relative = "cursor", col = 0, row = 1, anchor = "NW", style = "minimal" },
})
vim.fn["goda_skk#state_popup#enable"]()
-- }}}
