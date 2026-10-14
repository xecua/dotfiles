local notes = vim.g.typnote_dir
local function notes_root(path)
    if notes ~= nil and vim.startswith(path, notes .. "/") then
        return notes
    end
end

return {
    settings = {
        semanticTokens = "disable",
    },
    root_dir = function(bufnr, on_dir)
        local path = vim.api.nvim_buf_get_name(bufnr)
        on_dir(notes_root(path) or vim.fs.root(bufnr, { "typst.toml", ".git" }) or vim.fs.dirname(path))
    end,
}
