-- lua_add {{{
-- vim.g.loaded_ddu_rg = 1 -- prevent command definition by plugin

vim.keymap.set("n", "<Leader>fg", "<Cmd>call ddu#start(#{ name: 'rg-live'})<CR>")
vim.keymap.set("n", "<Leader>fls", "<Cmd>call ddu#start(#{ name: 'document-symbol'})<CR>")
vim.keymap.set("n", "<Leader>flw", "<Cmd>call ddu#start(#{ name: 'lsp-workspace-symbol'})<CR>")
vim.keymap.set("n", "<Leader>fp", "<Cmd>call ddu#start(#{ name: 'dpp'})<CR>")
vim.keymap.set("n", "<Leader>ffg", function()
    -- バッファがあればそのディレクトリ、なければカレントディレクトリを初期値にする
    local default = vim.fs.dirname(vim.api.nvim_buf_get_name(0)) or vim.uv.cwd()
    vim.ui.input({
        prompt = "Base directory: ",
        default = default,
        completion = "dir",
    }, function(input)
        vim.fn["ddu#start"]({
            name = "rg-live",
            sourceOptions = { rg = { path = input } },
        })
    end)
end)

vim.keymap.set("n", "<Leader>fd", "<Cmd>call ddu#start(#{ name: 'fd' })<CR>")
vim.keymap.set("n", "<Leader>ffd", "<Cmd>call ddu#start(#{ name: 'fd-all' })<CR>")
vim.keymap.set("n", "<Leader>fb", "<Cmd>Ddu buffer<CR>")
vim.keymap.set("n", "<Leader>ft", "<Cmd>Ddu ddt_tab<CR>")
vim.keymap.set("n", "<Leader>fr", "<Cmd>DduRg<CR>")

vim.keymap.set("n", "<C-n>", "<Cmd>call ddu#start(#{ name: 'fd-filer'})<CR>")

local ddu_group_id = vim.api.nvim_create_augroup("DduMyCnf", { clear = true })
vim.api.nvim_create_autocmd("User", {
    pattern = "Ddu:uiOpenFilterWindow",
    group = ddu_group_id,
    callback = function()
        vim.fn["ddc#custom#patch_global"]("ui", "none")
    end,
})

vim.api.nvim_create_autocmd("User", {
    pattern = "Ddu:uiCloseFilterWindow",
    group = ddu_group_id,
    callback = function()
        vim.fn["ddc#custom#patch_global"]("ui", "pum")
    end,
})

-- ddu-filerが最後のウィンドウになったら閉じる (fernと同様の挙動)
vim.api.nvim_create_autocmd("WinEnter", {
    group = ddu_group_id,
    callback = function()
        if vim.bo.filetype == "ddu-filer" and vim.fn.winnr("$") == 1 then
            vim.cmd("quit")
        end
    end,
})
-- }}}

-- lua_source {{{
vim.fn["ddu#custom#load_config"](vim.fn.stdpath("config") .. "/dpp/ddu.ts")
-- }}}
