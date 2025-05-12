return {
    init_options = {
        globalStoragePath = vim.env.HOME .. "/.local/share/intelephense",
        licenceKey = vim.env.HOME .. "/.local/share/intelephense/licence.txt",
    },
    root_dir = function(bufnr, on_dir)
        local fname = vim.api.nvim_buf_get_name(bufnr)
        local cwd = vim.uv.cwd()
        local root = vim.fs.root(fname, { "composer.json", ".git" })
        on_dir(root and vim.fs.relpath(cwd, root) and cwd or root)
    end,
}
