-- https://zenn.dev/rapan931/articles/45b09b774512fc
-- BufRead/BufNewFile -> FileType(これが呼ばれる) -> editorconfigが反映される -> BufReadPost -> modelineが反映される(filetypeがセットされてFileTypeイベントが発火するかも) -> BufWinEnter
-- なのでeditorconfigをこっちでなんかする必要なさそう

local hooks = {}

local function register_javascript_regex()
    -- regex string as text object
    vim.keymap.set("o", "i/", "<Cmd>normal! T/vt/<CR>", { buffer = true })
    vim.keymap.set("o", "a/", "<Cmd>normal! F/vf/<CR>", { buffer = true })
    vim.keymap.set("v", "i/", "<Cmd>normal! T/ot/<CR>", { buffer = true })
    vim.keymap.set("v", "a/", "<Cmd>normal! F/of/<CR>", { buffer = true })
end

local function indent_by_space(size)
    vim.opt_local.shiftwidth = size
end

local function indent_by_tab()
    vim.opt_local.expandtab = false
    vim.opt_local.shiftwidth = 0 -- -> use tabstop
end

hooks.markdown = function()
    indent_by_space(2)
    local line_count = vim.api.nvim_buf_line_count(0)
    if line_count == 1 then
        local content = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        if content[1] == "" then
            vim.notify("You are going to write markdown. How about use reST or Typst?")
        end
    end
end

hooks.astro = function()
    indent_by_space(2)
    register_javascript_regex()
end

hooks.c = function()
    indent_by_space(2)
end

hooks.cpp = function()
    indent_by_space(2)
end

hooks.dart = function()
    indent_by_space(2)
end

hooks.css = function()
    indent_by_space(2)
end

hooks.html = function()
    indent_by_space(2)
end

hooks.javascript = function()
    indent_by_space(2)
    register_javascript_regex()
end

hooks.javascriptreact = function()
    indent_by_space(2)
    register_javascript_regex()
end

hooks.typescript = function()
    indent_by_space(2)
    register_javascript_regex()
end

hooks.typescriptreact = function()
    indent_by_space(2)
    register_javascript_regex()
end

hooks.typespec = function()
    indent_by_space(2)
end

hooks.nix = function()
    indent_by_space(2)
end

hooks.json = function()
    indent_by_space(2)
end

hooks.jsonc = function()
    indent_by_space(2)
end

hooks.rst = function()
    indent_by_space(2)
end

hooks.satysfi = function()
    indent_by_space(2)
end

hooks.sql = function()
    indent_by_space(2)
end

hooks.vim = function()
    indent_by_space(2)
end

hooks.vue = function()
    indent_by_space(2)
    register_javascript_regex()
end

hooks.xml = function()
    indent_by_space(2)
end

hooks.yaml = function()
    indent_by_space(2)
end

hooks.go = function()
    indent_by_tab()
end

hooks.make = function()
    indent_by_tab()
end

hooks.csv = function()
    vim.opt_local.wrap = false
end

hooks.tsv = function()
    indent_by_tab()
    vim.opt_local.wrap = false
end

hooks.snippets = function()
    indent_by_tab()
end

hooks.tex = function()
    vim.opt_local.makeprg = "latexmk"
end

hooks.gitconfig = function()
    indent_by_tab()
end

hooks.php = function()
    -- テンプレートの場合はhtmlのルールに
    local bufname = vim.api.nvim_buf_get_name(0)
    if
        bufname:match("%.blade%.") -- Laravel Blade
        or bufname:match("%.twig%.") -- Twig (Symfony, Craft CMS)
        or bufname:match("%.ctp") -- CakePHP <= 3.x
        or bufname:match("/templates/") -- CakePHP >= 4.x
    then
        hooks.html()
    end
end

local M = {}
return setmetatable(M, {
    __index = function(_, key)
        return function()
            if hooks[key] then
                hooks[key]()
            else
                indent_by_space(4)
            end
        end
    end,
})
