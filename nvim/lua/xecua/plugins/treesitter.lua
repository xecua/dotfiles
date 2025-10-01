-- lua_add {{{
local augroup = vim.api.nvim_create_augroup("Treesitter", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    -- すべてのファイルでやってほしいのでpatternはなし
    callback = function()
        -- pcallでエラーを無視することでパーサーやクエリがあるか気にしなくてすむ
        local ok, _ = pcall(vim.treesitter.start)
        if ok then
            vim.wo.foldmethod = "expr"
            vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
    end,
})
-- }}}

-- lua_source {{{
require("nvim-treesitter").setup({
    install_dir = vim.fn.stdpath("cache") .. "/parsers",
})
-- }}}
