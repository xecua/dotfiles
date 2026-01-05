-- autocommands
local augroup = vim.api.nvim_create_augroup("Init", { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
    group = augroup,
    callback = function()
        local pos = vim.api.nvim_win_get_cursor(0)
        if vim.bo.filetype ~= "markdown" and vim.bo.filetype ~= "yaml.openapi" then
            vim.cmd([[silent! %s#\s\+$##e]])
        end
        vim.cmd([[silent! %s#\($\n\s*\)\+\%$##e]])
        pos[1] = math.min(pos[1], vim.api.nvim_buf_line_count(0))
        vim.api.nvim_win_set_cursor(0, pos)
    end,
    desc = "Remove redundant spaces and lines",
})
vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    pattern = {
        "astro",
        "c",
        "cpp",
        "dart",
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
        "sql",
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
    group = augroup,
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
    group = augroup,
    pattern = { "gitconfig", "go", "tsv" },
    callback = function()
        vim.opt_local.expandtab = false
    end,
})
vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    pattern = { "csv", "tsv" },
    callback = function()
        vim.opt_local.wrap = false
    end,
})
vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    pattern = "snippets",
    callback = function()
        vim.opt_local.expandtab = false
        vim.opt_local.softtabstop = -1
        vim.opt_local.shiftwidth = 0
        vim.opt_local.tabstop = 2
    end,
})
vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    pattern = "tex",
    callback = function()
        vim.opt_local.makeprg = "latexmk"
    end,
})
vim.api.nvim_create_autocmd(
    { "BufWritePost", "FileWritePost" },
    { group = augroup, pattern = { "*.saty", "*.tex" }, command = "QuickRun" }
)
if vim.fn.executable("pdftotext") == 1 then
    vim.api.nvim_create_autocmd({ "BufRead" }, {
        group = augroup,
        pattern = "*.pdf",
        command = [[enew | file #.txt | 0read !pdftotext -layout -nopgbrk "#" -]],
    })
end
-- automatically open QuickFix window after grep
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
    group = augroup,
    pattern = { "grep", "vimgrep" },
    command = "copen",
})
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
    group = augroup,
    pattern = { "lgrep", "lvimgrep" },
    command = "lopen",
})

vim.api.nvim_create_autocmd("ColorScheme", {
    group = augroup,
    pattern = "*",
    command = [[
        hi! CurSearch cterm=reverse gui=reverse
        hi link NormalFloat Normal
    ]],
})

vim.api.nvim_create_autocmd("User", {
    group = augroup,
    pattern = "DBUIOpened",
    command = "setl number",
})

vim.api.nvim_create_autocmd("BufEnter", {
    group = augroup,
    pattern = "*",
    callback = function()
        local path = string.gsub(vim.fn.expand("%:p"), "^" .. vim.fn.expand("$HOME"), "~")
        if path == "" then
            path = vim.fn.getcwd()
        end
        vim.opt.titlestring = "nvim: " .. vim.fn.pathshorten(path)
    end,
})
