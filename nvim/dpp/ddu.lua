-- lua_add {{{
-- vim.g.loaded_ddu_rg = 1 -- prevent command definition by plugin

vim.api.nvim_create_user_command("DduRgLive", function()
    vim.fn["ddu#start"]({
        sources = { { name = "rg", options = { volatile = true, matchers = {}, sorters = {} } } },
    })
end, {})
vim.api.nvim_create_user_command("DduLspDocumentSymbol", function()
    vim.fn["ddu#start"]({
        sources = { "lsp_documentSymbol" },
        uiParams = { ff = { displayTree = true } },
    })
end, {})
vim.api.nvim_create_user_command("DduLspWorkspaceSymbol", function()
    vim.fn["ddu#start"]({
        sources = { { name = "lsp_workspaceSymbol", options = { volatile = true } } },
        uiParams = { ff = { displayTree = true } },
    })
end, {})
vim.api.nvim_create_user_command("DduDpp", function()
    vim.fn["ddu#start"]({
        sources = { "dpp" },
        kindOptions = { file = { defaultAction = "cd" } },
    })
end, {})
vim.api.nvim_create_user_command("DduRgLiveRoot", function()
    -- バッファがあればそのディレクトリ、なければカレントディレクトリを初期値にする
    local default = vim.fs.dirname(vim.api.nvim_buf_get_name(0)) or vim.uv.cwd()
    vim.ui.input({
        prompt = "Base directory: ",
        default = default,
        completion = "dir",
    }, function(input)
        vim.fn["ddu#start"]({
            sources = {
                {
                    name = "rg",
                    options = { volatile = true, matchers = {}, sorters = {}, path = input },
                },
            },
        })
    end)
end, {})
vim.api.nvim_create_user_command("DduFileWithIgnored", function()
    vim.fn["ddu#start"]({
        sources = {
            {
                name = "file_external",
                params = { cmd = { "fd", ".", "-t", "f", "-H", "--no-ignore-vcs" } },
            },
        },
    })
end, {})

vim.keymap.set("n", "<Leader>fd", "<Cmd>Ddu file_external<CR>")
vim.keymap.set("n", "<Leader>ffd", "<Cmd>DduFileWithIgnored<CR>") -- 別のfd生やすならffdiとか
vim.keymap.set("n", "<Leader>ffg", "<Cmd>DduRgLiveRoot<CR>") -- 別のfg生やすならffgrとか
vim.keymap.set("n", "<Leader>fb", "<Cmd>Ddu buffer<CR>")
vim.keymap.set("n", "<Leader>ft", "<Cmd>Ddu ddt_tab<CR>")
vim.keymap.set("n", "<Leader>fg", "<Cmd>DduRgLive<CR>")
vim.keymap.set("n", "<Leader>fr", "<Cmd>DduRg<CR>")
vim.keymap.set("n", "<Leader>fj", "<Cmd>DduJvgrepLive<CR>")
vim.keymap.set("n", "<Leader>fls", "<Cmd>DduLspDocumentSymbol<CR>")
vim.keymap.set("n", "<Leader>flw", "<Cmd>DduLspWorkspaceSymbol<CR>")

vim.api.nvim_create_user_command("DduFiler", function()
    vim.fn["ddu#start"]({
        ui = "filer",
        sources = {
            {
                name = "file",
                options = {
                    columns = { "icon_filename" },
                    matchers = { "matcher_hidden" },
                    sorters = {},
                },
            },
        },
        actionOptions = {
            narrow = { quit = false },
            open = { quit = false },
            newFile = { quit = false },
            newDirectory = { quit = false },
            rename = { quit = false },
            yank = { quit = false },
            paste = { quit = false },
            trash = { quit = false },
        },
    })
end, {})
-- vim.keymap.set("n", "<C-n>", "<Cmd>DduFiler<CR>")

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
