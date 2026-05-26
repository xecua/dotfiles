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

local filetype_callback = require("xecua.filetype")
vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    pattern = "*",
    callback = function(args)
        filetype_callback[args.match]()
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

vim.api.nvim_create_autocmd("BufEnter", {
    group = augroup,
    pattern = "*",
    callback = function()
        local path = vim.fn.expand("%:p")
        if path == "" then
            local p, e = vim.uv.cwd()
            assert(p, e)
            path = p
        end
        local cwd = vim.fn.fnamemodify(path, ":h")
        local out = vim.system({ "git", "-C", cwd, "rev-parse", "--show-toplevel" }, { text = true, stderr = false })
            :wait()
        if out.code == 0 then
            local git_root_path = string.gsub(out.stdout, "\n", "")
            path = string.gsub(path, "^" .. vim.pesc(git_root_path), "")
            local git_root_name = vim.fn.fnamemodify(git_root_path, ":t")
            vim.opt.titlestring = "nvim: " .. git_root_name .. vim.fn.pathshorten(path)
        else
            path = string.gsub(path, "^" .. vim.pesc(vim.env.HOME), "~")
            vim.opt.titlestring = "nvim: " .. vim.fn.pathshorten(path)
        end
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    pattern = "*",
    callback = function()
        -- pcallでエラーを無視することでパーサーやクエリがあるか気にしなくてすむ
        local ok, _ = pcall(vim.treesitter.start)
        if ok then
            vim.wo.foldmethod = "expr"
            vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
            -- vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
    end,
})
