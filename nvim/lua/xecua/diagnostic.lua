vim.keymap.set("n", "<Leader>tq", "<Cmd>lua vim.diagnostic.setqflist()<CR>")
vim.keymap.set("n", "<Leader>tl", "<Cmd>lua vim.diagnostic.setloclist()<CR>")
vim.keymap.set("n", "<Leader>tf", "<Cmd>lua vim.diagnostic.open_float()<CR>")
vim.keymap.set("n", "<Leader>tt", function()
    vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "Toggle diagnostic" })

local function format_diag(diag)
    local s = string.format("%s: %s", diag.source, diag.message)
    if diag.code then
        s = string.format("%s [%s]", s, diag.code)
    end
    return s
end

vim.diagnostic.config({
    virtual_text = { format = format_diag },
    float = { border = "single", format = format_diag, suffix = "" },
    signs = false,
})
