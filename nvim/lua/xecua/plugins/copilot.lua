-- lua_add {{{
vim.g.copilot_no_tab_map = true
vim.g.copilot_filetypes = {
    ["*"] = true,
    ["dap-repl"] = false,
    markdown = false,
    dapui_watches = false,
    dapui_scopes = false,
    dapui_console = false,
    AvanteInput = false,
}

vim.keymap.set("i", "<C-l>", 'copilot#Accept("<C-l>")', { replace_keycodes = false, silent = true, expr = true })
vim.keymap.set("n", "<Leader>c", function()
    local input = vim.fn.input("Quick Chat: ")
    if input ~= "" then
        require("CopilotChat").ask(input, { selection = require("CopilotChat.select").buffer })
    end
end, { desc = "Copilot Quick Chat" })

-- }}}

-- lua_source {{{
local select = require("CopilotChat.select")

require("CopilotChat").setup({
    chat_autocomplete = false,
    prompts = {
        Explain = {
            prompt = "/COPILOT_EXPLAIN 選択されたコードの説明を段落をつけて書いてください。",
        },
        Review = {
            prompt = "/COPILOT_REVIEW 選択されたコードをレビューしてください。",
            callback = function(response, source) end,
        },
        Fix = {
            prompt = "/COPILOT_FIX このコードには問題があります。バグを修正したコードに書き直してください。",
        },
        Optimize = {
            prompt = "/COPILOT_REFACTOR 選択されたコードを最適化してパフォーマンスと可読性を向上させてください。",
        },
        Docs = {
            prompt = "/COPILOT_DOCS 選択されたコードに対してドキュメンテーションコメントを追加してください。",
        },
        Tests = {
            prompt = "/COPILOT_TESTS 選択されたコードの詳細な単体テスト関数を書いてください。",
        },
        FixDiagnostic = {
            prompt = "ファイル内の次のような診断上の問題を解決してください:",
            selection = select.diagnostics,
        },
    },
})

-- }}}
