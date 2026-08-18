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

vim.keymap.set("n", "<C-n>", function()
    local sources = {
        {
            name = "file_external",
            params = { cmd = { "fd", "--max-depth", "1", "--unrestricted" } },
        },
    }
    -- local buffer_name = vim.api.nvim_buf_get_name(0)
    -- local stat = vim.uv.fs_stat(buffer_name)
    -- if type(stat) == "table" and stat["type"] == "file" then
    --     -- 現在のファイルを↑とは別に出せばいい説があるけど、source毎に出ちゃうのでやっぱり無理かも
    --     vim.list_extend(sources, {
    --         {
    --             name = "file_external",
    --             params = { cmd = { "fd", "--unrestricted", buffer_name } },
    --         },
    --     })
    -- end
    vim.fn["ddu#start"]({
        name = "fd-filer",
        sources = sources,
    })
end)

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

-- lua_ddu-ff {{{
vim.opt_local.cursorline = true
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
vim.opt_local.number = true
vim.opt_local.cursorline = true

-- TODO: 開いたときに現在のファイルにカーソルが移動するやつ(頑張るしかない)
local opts = { buffer = true, silent = true }
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
        vim.fn["ddu#ui#do_action"]("itemAction", { name = "open", params = { command = "tabedit" } })
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
    local current = vim.fn["ddu#custom#get_current"](vim.b.ddu_ui_name)
    local matchers = ((current["sourceOptions"] or {})["file_external"] or {})["matchers"] or {}
    if vim.list_contains(matchers, "matcher_hidden") then
        matchers = vim.tbl_filter(function(matcher)
            return matcher ~= "matcher_hidden"
        end, matchers)
    else
        table.insert(matchers, "matcher_hidden")
    end

    vim.fn["ddu#ui#do_action"]("updateOptions", {
        sourceOptions = { file_external = { matchers = matchers } },
    })
    vim.fn["ddu#ui#do_action"]("redraw", { method = "refreshItems" })
end, opts)
-- }}}
