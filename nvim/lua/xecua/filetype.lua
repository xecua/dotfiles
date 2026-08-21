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

hooks.markdown = function()
    local line_count = vim.api.nvim_buf_line_count(0)
    if line_count == 1 then
        local content = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        if content[1] == "" then
            vim.notify("You are going to write markdown. How about use reST or Typst?")
        end
    end
end

hooks.astro = function()
    vim.opt_local.tabstop = 2
    register_javascript_regex()
end

hooks.c = function()
    vim.opt_local.tabstop = 2
end

hooks.cpp = function()
    vim.opt_local.tabstop = 2
end

hooks.dart = function()
    vim.opt_local.tabstop = 2
end

hooks.css = function()
    vim.opt_local.tabstop = 2
end

hooks.html = function()
    vim.opt_local.tabstop = 2
end

hooks.javascript = function()
    vim.opt_local.tabstop = 2
    register_javascript_regex()
end

hooks.javascriptreact = function()
    vim.opt_local.tabstop = 2
    register_javascript_regex()
end

hooks.typescript = function()
    vim.opt_local.tabstop = 2
    register_javascript_regex()
end

hooks.typescriptreact = function()
    vim.opt_local.tabstop = 2
    register_javascript_regex()
end

hooks.typespec = function()
    vim.opt_local.tabstop = 2
end

hooks.nix = function()
    vim.opt_local.tabstop = 2
end

hooks.json = function()
    vim.opt_local.tabstop = 2
end

hooks.jsonc = function()
    vim.opt_local.tabstop = 2
end

hooks.rst = function()
    vim.opt_local.tabstop = 2
end

hooks.satysfi = function()
    vim.opt_local.tabstop = 2
end

hooks.sql = function()
    vim.opt_local.tabstop = 2
end

hooks.vim = function()
    vim.opt_local.tabstop = 2
end

hooks.vue = function()
    vim.opt_local.tabstop = 2
    register_javascript_regex()
end

hooks.xml = function()
    vim.opt_local.tabstop = 2
end

hooks.yaml = function()
    vim.opt_local.tabstop = 2
end

hooks.go = function()
    vim.opt_local.expandtab = false
end

hooks.make = function()
    vim.opt_local.expandtab = false
end

hooks.csv = function()
    vim.opt_local.wrap = false
end

hooks.tsv = function()
    vim.opt_local.expandtab = false
    vim.opt_local.wrap = false
end

hooks.snippets = function()
    vim.opt_local.softtabstop = -1
    vim.opt_local.shiftwidth = 0
    vim.opt_local.expandtab = false
end

hooks.tex = function()
    vim.opt_local.makeprg = "latexmk"
end

hooks.gitconfig = function()
    vim.opt_local.expandtab = false
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
            end
        end
    end,
})
