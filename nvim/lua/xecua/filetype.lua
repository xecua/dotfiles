-- https://zenn.dev/rapan931/articles/45b09b774512fc

local M = {}

local function set_indent(tabstop, expandtab)
    if expandtab ~= nil then
        vim.opt_local.expandtab = false
    end
    if tabstop == nil then
        vim.opt_local.tabstop = tabstop
    end
end

local function register_javascript_regex()
    -- regex string as text object
    vim.keymap.set("o", "i/", "<Cmd>normal! T/vt/<CR>", { buffer = true })
    vim.keymap.set("o", "a/", "<Cmd>normal! F/vf/<CR>", { buffer = true })
    vim.keymap.set("v", "i/", "<Cmd>normal! T/ot/<CR>", { buffer = true })
    vim.keymap.set("v", "a/", "<Cmd>normal! F/of/<CR>", { buffer = true })
end

M.astro = function()
    set_indent(2)
    register_javascript_regex()
end

M.c = function()
    set_indent(2)
end

M.cpp = function()
    set_indent(2)
end

M.dart = function()
    set_indent(2)
end

M.css = function()
    set_indent(2)
end

M.html = function()
    set_indent(2)
end

M.javascript = function()
    set_indent(2)
    register_javascript_regex()
end

M.javascriptreact = function()
    set_indent(2)
    register_javascript_regex()
end

M.typescript = function()
    set_indent(2)
    register_javascript_regex()
end

M.typescriptreact = function()
    set_indent(2)
    register_javascript_regex()
end

M.typespec = function()
    set_indent(2)
end

M.json = function()
    set_indent(2)
end

M.jsonc = function()
    set_indent(2)
end

M.rst = function()
    set_indent(2)
end

M.satysfi = function()
    set_indent(2)
end

M.sql = function()
    set_indent(2)
end

M.vim = function()
    set_indent(2)
end

M.vue = function()
    set_indent(2)
    register_javascript_regex()
end

M.xml = function()
    set_indent(2)
end

M.yaml = function()
    set_indent(2)
end

M.go = function()
    set_indent(nil, false)
end

M.csv = function()
    vim.opt_local.wrap = false
end

M.tsv = function()
    set_indent(nil, false)
    vim.opt_local.wrap = false
end

M.snippets = function()
    vim.opt_local.softtabstop = -1
    vim.opt_local.shiftwidth = 0
    set_indent(2, false)
end

M.tex = function()
    vim.opt_local.makeprg = "latexmk"
end

M.gitconfig = function()
    set_indent(nil, false)
end

return setmetatable(M, {
    __index = function()
        return function()
            -- do nothing
        end
    end,
})
