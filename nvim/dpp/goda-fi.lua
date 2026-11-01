-- (lsp・dpp・ddt・filer は goda-fi に未実装なので ddu.lua に残している)

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
-- :DduRg 相当 (パターンを聞いてから検索する)
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
vim.keymap.set("n", "/", do_action("openFilterWindow"), opts)
vim.keymap.set("n", ",", do_action("toggleSelectItem"), opts)
vim.keymap.set("n", "t", do_action("toggleAllItems"), opts)
vim.keymap.set("n", "f", do_action("itemAction", { name = "quickfix" }), opts)
vim.keymap.set("n", "p", do_action("preview", { toggle = true }), opts)
-- h -> collapse, l -> expand (treeが生えたら)
vim.keymap.set("n", "q", do_action("quit"), opts)
-- }}}
