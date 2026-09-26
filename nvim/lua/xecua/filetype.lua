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
    register_javascript_regex()
end

hooks.javascript = function()
    register_javascript_regex()
end

hooks.javascriptreact = function()
    register_javascript_regex()
end

hooks.typescript = function()
    register_javascript_regex()
end

hooks.typescriptreact = function()
    register_javascript_regex()
end

hooks.vue = function()
    register_javascript_regex()
end

hooks.csv = function()
    vim.opt_local.wrap = false
end

hooks.tsv = function()
    vim.opt_local.wrap = false
end

hooks.tex = function()
    vim.opt_local.makeprg = "latexmk"
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

-- インデント幅。タブインデントは-1
M.indent_config = {
    markdown = 2,
    markdown_inline = 2,
    c = 2,
    cpp = 2,
    dart = 2,
    css = 2,
    html = 2,
    astro = 2,
    javascript = 2,
    javascriptreact = 2,
    typescript = 2,
    typescriptreact = 2,
    vue = 2,
    typespec = 2,
    nix = 2,
    json = 2,
    jsonc = 2,
    rst = 2,
    satisfy = 2,
    sql = 2,
    vim = 2,
    xml = 2,
    yaml = 2,
    go = -1,
    make = -1,
    tsv = -1,
    snippets = -1,
    gitconfig = -1,
}

M.configure_indent = function(size)
    if size == -1 then
        vim.opt_local.expandtab = false
        vim.opt_local.shiftwidth = 0 -- -> use tabstop
    else
        vim.opt_local.expandtab = true
        vim.opt_local.shiftwidth = size
    end
end

M.configure_indent_by_lang = function(lang)
    local indent_size = M.indent_config[lang] or 4
    M.configure_indent(indent_size)
end

return setmetatable(M, {
    __index = function(_, key)
        return function()
            if hooks[key] then
                hooks[key]()
            end
            M.configure_indent_by_lang(key)
        end
    end,
})
