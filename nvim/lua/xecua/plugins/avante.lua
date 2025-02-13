-- lua_source {{{
local model = nil
if vim.g.use_copilot then
    model = "copilot"
elseif vim.g.use_gemini then
    model = "gemini"
end

if model then
    require("avante_lib").load()

    require("avante").setup({
        provider = model,
        auto_suggestions_provider = model,
        copilot = {
            model = "gpt-4o",
        },
        gemini = {
            model = "gemini-2.0-flash",
        },
        behaviour = {
            auto_suggestions = vim.g.use_copilot,
            support_paste_from_clipboard = true,
            auto_set_keymaps = true, -- とりあえずね
        },
    })
end
-- }}}
