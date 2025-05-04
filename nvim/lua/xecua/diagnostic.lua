vim.keymap.set("n", "<Leader>tq", "<Cmd>lua vim.diagnostic.setqflist()<CR>")
vim.keymap.set("n", "<Leader>tl", "<Cmd>lua vim.diagnostic.setloclist()<CR>")
vim.keymap.set("n", "<Leader>tt", function()
    vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "Toggle diagnostic" })

vim.diagnostic.config({
    virtual_lines = {
        format = function(diag)
            local s = string.format("%s: %s", diag.source, diag.message)
            if diag.code then
                s = string.format("%s [%s]", s, diag.code)
            end
            return s
        end,
    },
    signs = false,
})
