-- lua_add {{{
local augroup = vim.api.nvim_create_augroup("GodaSkkConfig", { clear = true })

-- 辞書のパスはマシンごとに違うので環境変数でGoに渡す
-- このファイルをロードしている時点でgoda-pm.vimはrtpにいて、関数を呼べる
local goda_pm = require("goda_pm")
local skkdict_path = goda_pm.get("dict").path
local emoji_jisyo_path = goda_pm.get("skk-emoji-jisyo").path
local emoji_jisyo_ja_path = goda_pm.get("SKK-JISYO.emoji-ja").path
local base_dicts = {
    skkdict_path .. "/SKK-JISYO.L",
    skkdict_path .. "/SKK-JISYO.jinmei",
    skkdict_path .. "/SKK-JISYO.geo",
    skkdict_path .. "/SKK-JISYO.law",
    skkdict_path .. "/SKK-JISYO.station",
    skkdict_path .. "/SKK-JISYO.propernoun",
    skkdict_path .. "/SKK-JISYO.pinyin",
    skkdict_path .. "/SKK-JISYO.itaiji",
    skkdict_path .. "/SKK-JISYO.itaiji.JIS3_4",
    skkdict_path .. "/SKK-JISYO.JIS2004",
    skkdict_path .. "/SKK-JISYO.JIS2",
    skkdict_path .. "/SKK-JISYO.JIS3_4",
    emoji_jisyo_path .. "/SKK-JISYO.emoji.utf8",
    emoji_jisyo_ja_path .. "/SKK-JISYO.emoji-ja.utf8",
}
vim.env.GODA_SKK_DICTIONARIES = vim.json.encode(vim.list_extend(base_dicts, vim.g.skk_dictionaries or {}))

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
