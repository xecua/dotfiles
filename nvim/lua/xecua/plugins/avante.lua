-- lua_source {{{
local model = nil
if vim.g.use_copilot then
    -- model = "copilot"
    -- copilot-lspがあるからとcopilot.luaを消すとコイツが困る。Geminiあればとりあえずよくね?という説もあるしCodexとかもアリ
    -- あとはsidekick.nvimが一応chatもできる?
elseif vim.g.use_gemini then
    model = "gemini"
end

if model then
    vim.g.root_spec = { { ".git" }, "lsp", "cwd" }

    require("avante_lib").load()

    -- 自動補完はcopilotとかに投げるのでこっちでは不要
    require("avante").setup({
        provider = model,
        providers = {
            copilot = {
                model = "gpt-4.1", -- preq=0/1(free)
                -- model = "o4-mini", -- preq=0.33
            },
            gemini = {
                -- model = "gemini-2.5-flash", -- 10Req/Min, 250Req/Day for free
                model = "gemini-2.5-pro", -- 5Req/Min, 100Req/Day for free
            },
            -- gemmaとかをローカルで動かすのもアリ?
        },
        behaviour = {
            support_paste_from_clipboard = true,
            auto_set_keymaps = true, -- とりあえず
        },
    })
end
-- }}}
