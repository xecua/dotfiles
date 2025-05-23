-- lua_source {{{
local model = nil
if vim.g.use_copilot then
    model = "copilot"
elseif vim.g.use_gemini then
    model = "gemini"
end

if model then
    require("avante_lib").load()

    -- 自動補完はcopilotとかに投げるのでこっちでは不要
    require("avante").setup({
        provider = model,
        copilot = {
            model = "gpt-4.1", -- preq=0/1(free)
            -- model = "o4-mini", -- preq=0.33
        },
        gemini = {
            -- model = "gemini-2.5-flash-preview-05-20", -- 10Req/Min, 500Req/Day for free
            model = "gemini-2.5-pro-preview-05-06", -- 5Req/Min, 25Req/Day for free
        },
        behaviour = {
            support_paste_from_clipboard = true,
            auto_set_keymaps = true, -- とりあえずね
        },
    })
end
-- }}}
