if vim.g.vscode then
    return
end

local utils = require("xecua.utils")

-- Switching automatic punctuation substitution
local punct_sub_augroup_id = vim.api.nvim_create_augroup("PunctSub", { clear = true })
vim.api.nvim_create_user_command("PunctSubEnable", function()
    vim.api.nvim_create_autocmd({ "BufWritePre", "FileWritePre" }, {
        group = punct_sub_augroup_id,
        buffer = 0, -- current buffer (like other apis; not documented, though)
        callback = utils.normalize_punctuation,
    })
end, {})
vim.api.nvim_create_user_command("PunctSubDisable", function()
    for _, autocmd in
        pairs(vim.api.nvim_get_autocmds({
            group = punct_sub_augroup_id,
            buffer = 0,
        }))
    do
        vim.api.nvim_del_autocmd(autocmd.id)
    end
end, {})
-- LaTeX and SATySFi: enable by default
vim.api.nvim_create_autocmd(
    { "BufWritePre", "FileWritePre" },
    { group = punct_sub_augroup_id, pattern = { "*.saty", "*.tex", "*.typ" }, command = "PunctSubEnable" }
)
