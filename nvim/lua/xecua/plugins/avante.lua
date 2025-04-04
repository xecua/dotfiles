-- lua_source {{{
local model = nil
if vim.g.use_copilot then
    model = "copilot"
elseif vim.g.use_gemini then
    model = "gemini"
end

if model then
    require("avante_lib").load()

    -- コード生成にはo1とかのReasoning model=推論モデルがいいらしい。gpt-4oはマルチモーダル対応、あと速い。
    -- gemini: 無料で投げられるリクエストが多い。flashは軽くてproはコンテキストがでかい。thinkingが推論モデル。
    -- 自動補間はcopilot.vim/tabnine.vimに投げるのでこっちでは不要
    require("avante").setup({
        provider = model,
        copilot = {
            model = "gpt-4o", -- no limit
            -- model = "o3-mini", -- 50Req/12h
        },
        gemini = {
            -- model = "gemini-2.0-flash", -- 15Req/Min, 1500Req/Day for free
            model = "gemini-2.0-flash-thinking-exp", -- 10Req/Min, 1500Req/Day for free
        },
        behaviour = {
            support_paste_from_clipboard = true,
            auto_set_keymaps = true, -- とりあえずね
        },
    })
end
-- }}}
