-- lua_add {{{
local function start(options)
    vim.fn["goda_fi#start"](options)
end

vim.keymap.set("n", "<Leader>fg", function()
    start({ name = "rg-live" })
end)
vim.keymap.set("n", "<Leader>ffg", function()
    -- バッファがあればそのディレクトリ、なければカレントディレクトリを初期値にする
    local default = vim.fs.dirname(vim.api.nvim_buf_get_name(0)) or vim.uv.cwd()
    vim.ui.input({
        prompt = "Base directory: ",
        default = default,
        completion = "dir",
    }, function(input)
        if input == nil then
            return
        end
        start({
            name = "rg-live",
            sourceOptions = { rg = { path = input } },
        })
    end)
end)
vim.keymap.set("n", "<Leader>fd", function()
    start({ name = "fd" })
end)
vim.keymap.set("n", "<Leader>ffd", function()
    start({ name = "fd-all" })
end)
vim.keymap.set("n", "<Leader>fb", function()
    start({ name = "buffer" })
end)
vim.keymap.set("n", "<Leader>fr", function()
    vim.ui.input({ prompt = "Pattern: " }, function(input)
        if input == nil or input == "" then
            return
        end
        start({
            name = "rg",
            sourceParams = { rg = { input = input } },
        })
    end)
end)

-- filerでpathまでツリーを展開してカーソルを合わせる。
local function reveal_in_filer(path, root)
    local dirs = {}
    for dir in vim.fs.parents(path) do
        if dir == root then
            break
        end
        table.insert(dirs, 1, dir)
    end

    -- 子の収集・描画は非同期なので、カーソルが目的の項目に来るまで待つ
    local function wait_cursor_on(p)
        return vim.wait(1000, function()
            local item = vim.fn["goda_fi#ui#get_item"]("filer")
            return type(item.action) == "table" and item.action.path == p
        end, 10)
    end

    for _, dir in ipairs(dirs) do
        start({ name = "filer", resume = true, searchPath = dir })
        if not wait_cursor_on(dir) then
            return
        end
        vim.fn["goda_fi#ui#do_action"]("expandItem", vim.empty_dict(), "filer")
    end
    start({ name = "filer", resume = true, searchPath = path })
end

-- toggleはLua側でやる (uiOptionsのtoggleだとreveal_in_filerのresumeで閉じてしまう)
vim.keymap.set("n", "<C-n>", function()
    if vim.fn["goda_fi#ui#visible"]("filer") == 1 then
        vim.fn["goda_fi#ui#do_action"]("quit", vim.empty_dict(), "filer")
        return
    end

    local buffer_name = vim.api.nvim_buf_get_name(0)
    local cwd = vim.fn.getcwd()
    local stat = vim.uv.fs_stat(buffer_name)

    start({ name = "filer" })
    if stat and stat.type == "file" and vim.startswith(buffer_name, cwd .. "/") then
        reveal_in_filer(buffer_name, cwd)
    end
end)

local augroup = vim.api.nvim_create_augroup("GodaFiConfig", { clear = true })

-- filerからファイルを開く先として、最後にいた通常のウィンドウを覚えておく (`wincmd p` はプラグイン側のwin_gotoidなどで前のウィンドウが変わってしまい当てにならない)
vim.api.nvim_create_autocmd("WinLeave", {
    group = augroup,
    callback = function()
        if
            vim.api.nvim_win_get_config(0).relative == ""
            and vim.bo.buftype == ""
            and not vim.startswith(vim.bo.filetype, "goda-fi-")
        then
            vim.t.goda_fi_filer_target_win = vim.api.nvim_get_current_win()
        end
    end,
})

-- filerが最後のウィンドウになったら閉じる
vim.api.nvim_create_autocmd("WinEnter", {
    group = augroup,
    callback = function()
        if vim.bo.filetype == "goda-fi-filer" and vim.fn.winnr("$") == 1 then
            vim.cmd("quit")
        end
    end,
})
-- }}}

-- lua_goda-fi-ff {{{
vim.opt_local.cursorline = true
local opts = { buffer = true, silent = true }

local function do_action(action, params)
    return function()
        vim.fn["goda_fi#ui#do_action"](action, params or vim.empty_dict())
    end
end

vim.keymap.set("n", "<CR>", do_action("itemAction"), opts)
vim.keymap.set("n", "a", do_action("chooseAction"), opts)
vim.keymap.set("n", "/", do_action("openFilterWindow"), opts)
vim.keymap.set("n", ",", do_action("toggleSelectItem"), opts)
vim.keymap.set("n", "t", do_action("toggleAllItems"), opts)
vim.keymap.set("n", "f", do_action("itemAction", { name = "quickfix" }), opts)
vim.keymap.set("n", "p", do_action("togglePreview"), opts)
vim.keymap.set("n", "h", do_action("collapseItem"), opts)
vim.keymap.set("n", "l", do_action("expandItem"), opts)
vim.keymap.set("n", "q", do_action("quit"), opts)
-- }}}

-- lua_goda-fi-filer {{{
vim.opt_local.number = true
vim.opt_local.cursorline = true

local opts = { buffer = true, silent = true }

local function do_action(action, params)
    vim.fn["goda_fi#ui#do_action"](action, params or vim.empty_dict())
end
local function item_action(name, params)
    return function()
        do_action("itemAction", { name = name, params = params })
    end
end
local function get_item()
    return vim.fn["goda_fi#ui#get_item"]()
end

-- 最後にいた通常のウィンドウに移動してからcmdを実行するコマンド文字列
local function open_command(cmd)
    local win = vim.t.goda_fi_filer_target_win
    if win and vim.api.nvim_win_is_valid(win) then
        return string.format("call win_gotoid(%d)|%s", win, cmd)
    end
    return "wincmd p|" .. cmd
end
-- ディレクトリ以外ならcmdで開く
local function open_file(cmd)
    return function()
        if not get_item().isTree then
            do_action("itemAction", { name = "open", params = { command = cmd() } })
        end
    end
end

vim.keymap.set("n", "h", function()
    do_action("collapseItem")
end, opts)
vim.keymap.set("n", "d", item_action("trash"), opts)
-- LSPのdidChangeとかを発動したい
vim.keymap.set("n", "N", item_action("newFile"), opts)
vim.keymap.set("n", "K", item_action("newDirectory"), opts)
vim.keymap.set("n", "R", item_action("rename"), opts)
vim.keymap.set("n", "y", item_action("yank"), opts)
vim.keymap.set("n", "c", item_action("copy"), opts)
vim.keymap.set("n", "m", item_action("move"), opts)
vim.keymap.set("n", "p", item_action("paste"), opts)
vim.keymap.set("n", "u", item_action("undo"), opts)

vim.keymap.set(
    "n",
    "s",
    open_file(function()
        return open_command("wincmd s|drop")
    end),
    opts
)
vim.keymap.set(
    "n",
    "v",
    open_file(function()
        return open_command("wincmd v|drop")
    end),
    opts
)
vim.keymap.set(
    "n",
    "t",
    open_file(function()
        return "tabedit"
    end),
    opts
)
vim.keymap.set(
    "n",
    "e",
    open_file(function()
        local picked_window_id = require("window-picker").pick_window()
        return vim.api.nvim_win_get_number(picked_window_id) .. "wincmd w|drop"
    end),
    opts
)
vim.keymap.set("n", "l", function()
    if get_item().isTree then
        do_action("expandItem", { isInTree = true })
    else
        do_action("itemAction", { name = "open", params = { command = open_command("drop") } })
    end
end, opts)
vim.keymap.set("n", "<LeftRelease>", function()
    local item = get_item()
    if item.isTree and item.__expanded then
        do_action("collapseItem")
    elseif item.isTree then
        do_action("expandItem", { isInTree = true })
    else
        do_action("itemAction", { name = "open", params = { command = open_command("drop") } })
    end
end, opts)

vim.keymap.set("n", "<CR>", function()
    if get_item().isTree then
        do_action("itemAction", { name = "narrow" })
    else
        do_action("itemAction", { name = "open", params = { command = open_command("drop") } })
    end
end, opts)
vim.keymap.set("n", "<BS>", item_action("narrow", { path = ".." }), opts)

-- 隠しファイルの表示切り替え
vim.keymap.set("n", "!", function()
    local current = vim.fn["goda_fi#custom#get_current"]()
    local matchers = vim.deepcopy(((current.sourceOptions or {}).file or {}).matchers or {})
    if vim.list_contains(matchers, "matcherhidden") then
        matchers = vim.tbl_filter(function(matcher)
            return matcher ~= "matcherhidden"
        end, matchers)
    else
        table.insert(matchers, 1, "matcherhidden")
    end

    do_action("updateOptions", { sourceOptions = { file = { matchers = matchers } } })
    do_action("redraw")
end, opts)
-- }}}
