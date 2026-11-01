-- lua_add {{{
vim.keymap.set("n", "<C-n>", function()
    local ddu_args = { name = "fd-filer" }

    local buffer_name = vim.api.nvim_buf_get_name(0)
    local cwd = vim.uv.cwd()
    local stat = vim.uv.fs_stat(buffer_name)
    if stat and stat.type == "file" and cwd and vim.startswith(buffer_name, cwd .. "/") then
        ddu_args.searchPath = buffer_name
    end

    vim.fn["ddu#start"](ddu_args)
end)

local ddu_group_id = vim.api.nvim_create_augroup("DduMyCnf", { clear = true })
--[[ vim.api.nvim_create_autocmd("User", {
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
}) ]]

-- ddu-filerからファイルを開く先として、最後にいた通常のウィンドウを覚えておく
-- (`wincmd p` はプラグイン側のwin_gotoidなどで前のウィンドウが変わってしまい当てにならない)
vim.api.nvim_create_autocmd({ "WinEnter", "BufWinEnter" }, {
    group = ddu_group_id,
    callback = function()
        if
            vim.api.nvim_win_get_config(0).relative == ""
            and vim.bo.buftype == ""
            and not vim.startswith(vim.bo.filetype, "ddu-")
        then
            vim.t.ddu_filer_target_win = vim.api.nvim_get_current_win()
        end
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

-- lua_ddu-filer {{{
vim.opt_local.number = true
vim.opt_local.cursorline = true

local opts = { buffer = true, silent = true }

-- 最後にいた通常のウィンドウに移動してからcmdを実行するコマンド文字列
local function open_command(cmd)
    local win = vim.t.ddu_filer_target_win
    if win and vim.api.nvim_win_is_valid(win) then
        return string.format("call win_gotoid(%d)|%s", win, cmd)
    end
    return "wincmd p|" .. cmd
end

vim.keymap.set("n", "h", "<Cmd>call ddu#ui#do_action('collapseItem')<CR>", opts)
vim.keymap.set("n", "d", "<Cmd>call ddu#ui#do_action('itemAction', #{name: 'trash' })<CR>", opts)
-- LSPのdidChangeとかを発動したい
vim.keymap.set("n", "N", "<Cmd>call ddu#ui#do_action('itemAction', #{name: 'newFile' })<CR>", opts)
vim.keymap.set("n", "K", "<Cmd>call ddu#ui#do_action('itemAction', #{name: 'newDirectory' })<CR>", opts)
vim.keymap.set("n", "R", "<Cmd>call ddu#ui#do_action('itemAction', #{name: 'rename' })<CR>", opts)
vim.keymap.set("n", "y", "<Cmd>call ddu#ui#do_action('itemAction', #{name: 'yank' })<CR>", opts)
vim.keymap.set("n", "c", "<Cmd>call ddu#ui#do_action('itemAction', #{name: 'copy' })<CR>", opts)
vim.keymap.set("n", "m", "<Cmd>call ddu#ui#do_action('itemAction', #{name: 'move' })<CR>", opts)
vim.keymap.set("n", "p", "<Cmd>call ddu#ui#do_action('itemAction', #{name: 'paste' })<CR>", opts)

vim.keymap.set("n", "s", function()
    if not vim.fn["ddu#ui#get_item"]()["isTree"] then
        vim.fn["ddu#ui#do_action"](
            "itemAction",
            { name = "open", params = { command = open_command("wincmd s|drop") } }
        )
    end
end, opts)
vim.keymap.set("n", "v", function()
    if not vim.fn["ddu#ui#get_item"]()["isTree"] then
        vim.fn["ddu#ui#do_action"](
            "itemAction",
            { name = "open", params = { command = open_command("wincmd v|drop") } }
        )
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
        vim.fn["ddu#ui#do_action"]("itemAction", { name = "open", params = { command = open_command("drop") } })
    end
end, opts)
vim.keymap.set("n", "<LeftRelease>", function()
    local item = vim.fn["ddu#ui#get_item"]()
    if item["isTree"] and item["__expanded"] then
        vim.fn["ddu#ui#do_action"]("collapseItem")
    elseif item["isTree"] then
        vim.fn["ddu#ui#do_action"]("expandItem", { isInTree = true })
    else
        vim.fn["ddu#ui#do_action"]("itemAction", { name = "open", params = { command = open_command("drop") } })
    end
end, opts)

vim.keymap.set("n", "<CR>", function()
    if vim.fn["ddu#ui#get_item"]()["isTree"] then
        vim.fn["ddu#ui#do_action"]("itemAction", { name = "narrow" })
    else
        vim.fn["ddu#ui#do_action"]("itemAction", { name = "open", params = { command = open_command("drop") } })
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
