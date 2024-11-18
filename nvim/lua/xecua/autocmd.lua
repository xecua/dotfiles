-- autocommands
local init_augroup_id = vim.api.nvim_create_augroup("Init", { clear = true })
vim.api.nvim_create_autocmd(
    "BufWritePre",
    { group = init_augroup_id, command = [[silent! %s#\($\n\s*\)\+\%$##]], desc = "Remove redundant lines" }
)
vim.api.nvim_create_autocmd("FileType", {
    group = init_augroup_id,
    pattern = {
        "astro",
        "c",
        "cpp",
        "dart",
        "fish",
        "css",
        "html",
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "typespec",
        "json",
        "jsonc",
        "rst",
        "satysfi",
        "vim",
        "vue",
        "xml",
        "yaml",
    },
    callback = function()
        vim.opt_local.tabstop = 2
    end,
})
vim.api.nvim_create_autocmd("FileType", {
    group = init_augroup_id,
    pattern = {
        "astro",
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "vue",
    },
    callback = function()
        -- regex string as text object
        vim.keymap.set("o", "i/", "<Cmd>normal! T/vt/<CR>")
        vim.keymap.set("o", "a/", "<Cmd>normal! F/vf/<CR>")
        vim.keymap.set("v", "i/", "<Cmd>normal! T/ot/<CR>")
        vim.keymap.set("v", "a/", "<Cmd>normal! F/of/<CR>")
    end,
})
vim.api.nvim_create_autocmd("FileType", {
    group = init_augroup_id,
    pattern = { "gitconfig", "go", "tsv" },
    callback = function()
        vim.opt_local.expandtab = false
    end,
})
vim.api.nvim_create_autocmd("FileType", {
    group = init_augroup_id,
    pattern = { "csv", "tsv" },
    callback = function()
        vim.opt_local.wrap = false
    end,
})
vim.api.nvim_create_autocmd("FileType", {
    group = init_augroup_id,
    pattern = "snippets",
    callback = function()
        vim.opt_local.expandtab = false
        vim.opt_local.softtabstop = -1
        vim.opt_local.shiftwidth = 0
        vim.opt_local.tabstop = 2
    end,
})
vim.api.nvim_create_autocmd("FileType", {
    group = init_augroup_id,
    pattern = "tex",
    callback = function()
        vim.opt_local.makeprg = "latexmk"
    end,
})
vim.api.nvim_create_autocmd(
    { "BufWritePost", "FileWritePost" },
    { group = init_augroup_id, pattern = { "*.saty", "*.tex" }, command = "QuickRun" }
)
if vim.fn.executable("pdftotext") == 1 then
    vim.api.nvim_create_autocmd({ "BufRead" }, {
        group = init_augroup_id,
        pattern = "*.pdf",
        command = [[enew | file #.txt | 0read !pdftotext -layout -nopgbrk "#" -]],
    })
end
-- automatically open QuickFix window after grep
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
    group = init_augroup_id,
    pattern = { "grep", "vimgrep" },
    command = "copen",
})
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
    group = init_augroup_id,
    pattern = { "lgrep", "lvimgrep" },
    command = "lopen",
})

vim.api.nvim_create_autocmd("ColorScheme", {
    group = init_augroup_id,
    pattern = "*",
    command = [[
        hi! CurSearch cterm=reverse gui=reverse
        hi link NormalFloat Normal
    ]],
})

vim.api.nvim_create_autocmd("FileType", {
    group = init_augroup_id,
    pattern = "dbui",
    command = "setl number",
})

vim.api.nvim_create_autocmd("BufEnter", {
    group = init_augroup_id,
    pattern = "*",
    callback = function()
        local path = string.gsub(vim.fn.expand("%:p"), "^" .. vim.fn.expand("$HOME"), "~")
        if path == "" then
            path = vim.fn.getcwd()
        end
        vim.opt.titlestring = "nvim: " .. vim.fn.pathshorten(path)
    end,
})
