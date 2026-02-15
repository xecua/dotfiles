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
vim.keymap.set("n", "<Leader>fd", "<Cmd>Ddu file_external<CR>")
vim.keymap.set("n", "<Leader>fb", "<Cmd>Ddu buffer<CR>")
vim.keymap.set("n", "<Leader>ft", "<Cmd>Ddu ddt_tab<CR>")
vim.keymap.set("n", "<Leader>fg", "<Cmd>DduRgLive<CR>")
vim.keymap.set("n", "<Leader>fr", "<Cmd>DduRg<CR>")
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
-- }}}

-- lua_source {{{
vim.fn["ddu#custom#load_config"](vim.fn.stdpath("config") .. "/dpp/ddu.ts")
-- }}}

-- lua_ddu-ff {{{
local opts = { buffer = true, silent = true }
vim.keymap.set("n", "<CR>", "<Cmd>call ddu#ui#do_action('itemAction')<CR>", opts)
-- function()
--     local item = vim.fn["ddu#ui#get_item"]()
--     if item["__sourceName"] == "rg" then
--       -- wincmd pだとpreviewに行ってしまうのでダメ
--     end
--     vim.fn["ddu#ui#do_action"]("itemAction")
-- end, opts)
vim.keymap.set("n", "a", "<Cmd>call ddu#ui#do_action('chooseAction')<CR>", opts)
vim.keymap.set("n", "/", "<Cmd>call ddu#ui#do_action('openFilterWindow')<CR>", opts)
vim.keymap.set("n", ",", "<Cmd>call ddu#ui#do_action('toggleSelectItem')<CR>", opts)
vim.keymap.set("n", "t", "<Cmd>call ddu#ui#do_action('toggleAllItems')<CR>", opts)
vim.keymap.set("n", "f", "<Cmd>call ddu#ui#do_action('itemAction', #{ name: 'quickfix' })<CR>", opts)
vim.keymap.set("n", "p", "<Cmd>call ddu#ui#do_action('togglePreview')<CR>", opts)
vim.keymap.set("n", "h", "<Cmd>call ddu#ui#do_action('collapseItem')<CR>", opts)
vim.keymap.set("n", "l", "<Cmd>call ddu#ui#do_action('expandItem')<CR>", opts)
vim.keymap.set("n", "q", "<Cmd>call ddu#ui#do_action('quit')<CR>", opts)

-- }}}

-- lua_ddu-filer {{{
-- TODO: 開いたときに現在のファイルにカーソルが移動するやつ(頑張るしかない)とウィンドウ選んで(適当なプラグインを使おう)ファイルを開けるやつ
vim.opt_local.number = true
local opts = { buffer = true, silent = true }
vim.keymap.set("n", "a", "<Cmd>call ddu#ui#do_action('chooseAction')<CR>", opts)
vim.keymap.set("n", "h", "<Cmd>call ddu#ui#do_action('collapseItem')<CR>", opts)
vim.keymap.set("n", "d", "<Cmd>call ddu#ui#do_action('itemAction', #{name: 'trash' })<CR>", opts)
vim.keymap.set("n", "N", "<Cmd>call ddu#ui#do_action('itemAction', #{name: 'newFile' })<CR>", opts)
vim.keymap.set("n", "K", "<Cmd>call ddu#ui#do_action('itemAction', #{name: 'newDirectory' })<CR>", opts)
vim.keymap.set("n", "R", "<Cmd>call ddu#ui#do_action('itemAction', #{name: 'rename' })<CR>", opts)
vim.keymap.set("n", "y", "<Cmd>call ddu#ui#do_action('itemAction', #{name: 'yank' })<CR>", opts)
vim.keymap.set("n", "p", "<Cmd>call ddu#ui#do_action('itemAction', #{name: 'paste' })<CR>", opts)

vim.keymap.set("n", "s", function()
    if not vim.fn["ddu#ui#get_item"]()["isTree"] then
        vim.fn["ddu#ui#do_action"]("itemAction", { name = "open", params = { command = "wincmd p|wincmd s|drop" } })
    end
end, opts)
vim.keymap.set("n", "v", function()
    if not vim.fn["ddu#ui#get_item"]()["isTree"] then
        vim.fn["ddu#ui#do_action"]("itemAction", { name = "open", params = { command = "wincmd p|wincmd v|drop" } })
    end
end, opts)
vim.keymap.set("n", "t", function()
    if not vim.fn["ddu#ui#get_item"]()["isTree"] then
        vim.fn["ddu#ui#do_action"]("itemAction", { name = "open", params = { command = "tab drop" } })
    end
end, opts)
vim.keymap.set("n", "e", function()
    if not vim.fn["ddu#ui#get_item"]()["isTree"] then
        local picked_window_id = require("window-picker").pick_window()
        local picked_window_nr = vim.api.nvim_win_get_number(picked_window_id)
        vim.fn["ddu#ui#do_action"](
            "itemAction",
            { name = "open", params = { command = picked_window_nr .. "wincmd w|drop" } }
        )
    end
end, opts)
vim.keymap.set("n", "l", function()
    if vim.fn["ddu#ui#get_item"]()["isTree"] then
        vim.fn["ddu#ui#do_action"]("expandItem", { isInTree = true })
        -- isInTreeがtrueなら↓も呼んでくれてはいるんだけど効かん……
        vim.fn["ddu#ui#do_action"]("cursorNext")
    else
        vim.fn["ddu#ui#do_action"]("itemAction", { name = "open", params = { command = "wincmd p|drop" } })
    end
end, opts)
vim.keymap.set("n", "<LeftRelease>", function()
    local item = vim.fn["ddu#ui#get_item"]()
    if item["isTree"] and item["__expanded"] then
        vim.fn["ddu#ui#do_action"]("collapseItem")
    elseif item["isTree"] then
        vim.fn["ddu#ui#do_action"]("expandItem", { isInTree = true })
    else
        vim.fn["ddu#ui#do_action"]("itemAction", { name = "open", params = { command = "wincmd p|drop" } })
    end
end, opts)

vim.keymap.set("n", "<CR>", function()
    if vim.fn["ddu#ui#get_item"]()["isTree"] then
        vim.fn["ddu#ui#do_action"]("itemAction", { name = "narrow" })
    else
        vim.fn["ddu#ui#do_action"]("itemAction", { name = "open", params = { command = "wincmd p|drop" } })
    end
end, opts)

vim.keymap.set(
    "n",
    "<BS>",
    "<Cmd>call ddu#ui#do_action('itemAction', #{ name: 'narrow', params: #{ path: '..' } })<CR>",
    opts
)

vim.keymap.set("n", "!", function()
    -- これdocに記載されてるやり方だから↑のヒントになりそう
    local current = vim.fn["ddu#custom#get_current"](vim.b.ddu_ui_name)
    local matchers = ((current["sourceOptions"] or {})["file"] or {})["matchers"] or {}
    if #matchers == 0 then
        matchers = { "matcher_hidden" }
    else
        matchers = {}
    end

    vim.print(current["sourceOptions"])

    vim.fn["ddu#ui#do_action"]("updateOptions", {
        sourceOptions = { file = { matchers = matchers } },
    })
    vim.fn["ddu#ui#do_action"]("redraw", { method = "refreshItems" })
end, opts)
-- }}}
