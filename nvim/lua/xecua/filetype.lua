-- https://zenn.dev/rapan931/articles/45b09b774512fc

local hooks = {}

local function set_no_leading_char()
    local listchars = vim.opt.listchars:get()
    listchars.leadmultispace = nil
    listchars.leadtab = nil
    vim.opt_local.listchars = listchars
end

local function set_indent(tabstop, expandtab)
    if tabstop ~= nil then
        vim.opt_local.tabstop = tabstop
        vim.opt_local.listchars =
            vim.tbl_extend("force", vim.opt.listchars:get(), { leadmultispace = ">" .. string.rep("･", tabstop - 1) })
    end
    if expandtab ~= nil then
        vim.opt_local.expandtab = expandtab
    end
end
local function load_editorconfig()
    local editorconfig = vim.b.editorconfig or {}
    if editorconfig.indent_style then
        set_indent(nil, editorconfig.indent_style == "space")
    end
    if editorconfig.indent_size then
        set_indent(tonumber(editorconfig.indent_size))
    end
end

local function register_javascript_regex()
    -- regex string as text object
    vim.keymap.set("o", "i/", "<Cmd>normal! T/vt/<CR>", { buffer = true })
    vim.keymap.set("o", "a/", "<Cmd>normal! F/vf/<CR>", { buffer = true })
    vim.keymap.set("v", "i/", "<Cmd>normal! T/ot/<CR>", { buffer = true })
    vim.keymap.set("v", "a/", "<Cmd>normal! F/of/<CR>", { buffer = true })
end

hooks.astro = function()
    set_indent(2)
    register_javascript_regex()
end

hooks.c = function()
    set_indent(2)
end

hooks.cpp = function()
    set_indent(2)
end

hooks.dart = function()
    set_indent(2)
end

hooks.css = function()
    set_indent(2)
end

hooks.html = function()
    set_indent(2)
end

hooks.javascript = function()
    set_indent(2)
    register_javascript_regex()
end

hooks.javascriptreact = function()
    set_indent(2)
    register_javascript_regex()
end

hooks.typescript = function()
    set_indent(2)
    register_javascript_regex()
end

hooks.typescriptreact = function()
    set_indent(2)
    register_javascript_regex()
end

hooks.typespec = function()
    set_indent(2)
end

hooks.nix = function()
    set_indent(2)
end

hooks.json = function()
    set_indent(2)
end

hooks.jsonc = function()
    set_indent(2)
end

hooks.rst = function()
    set_indent(2)
end

hooks.satysfi = function()
    set_indent(2)
end

hooks.sql = function()
    set_indent(2)
end

hooks.vim = function()
    set_indent(2)
end

hooks.vue = function()
    set_indent(2)
    register_javascript_regex()
end

hooks.xml = function()
    set_indent(2)
end

hooks.yaml = function()
    set_indent(2)
end

hooks.go = function()
    set_indent(nil, false)
end

hooks.make = function()
    set_indent(nil, false)
end

hooks.csv = function()
    vim.opt_local.wrap = false
end

hooks.tsv = function()
    set_indent(nil, false)
    vim.opt_local.wrap = false
end

hooks.snippets = function()
    vim.opt_local.softtabstop = -1
    vim.opt_local.shiftwidth = 0
    set_indent(2, false)
end

hooks.tex = function()
    vim.opt_local.makeprg = "latexmk"
end

hooks.gitconfig = function()
    set_indent(nil, false)
end

hooks["dap-view"] = function()
    set_no_leading_char()
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

            -- editorconfigを優先
            load_editorconfig()
        end
    end,
})
