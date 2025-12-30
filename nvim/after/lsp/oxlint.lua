local util = require("lspconfig.util")

return {
    cmd = function(dispatchers, config)
        local cmd = "oxlint"
        local local_cmd = (config or {}).root_dir and config.root_dir .. "/node_modules/.bin/oxlint"
        if local_cmd and vim.fn.executable(local_cmd) == 1 then
            cmd = local_cmd
        end
        return vim.lsp.rpc.start({ cmd, "--type-aware", "--lsp" }, dispatchers)
    end,
    filetypes = {
        "javascript",
        "javascriptreact",
        "javascript.jsx",
        "typescript",
        "typescriptreact",
        "typescript.tsx",
    },
    workspace_required = true,
    root_dir = function(bufnr, on_dir)
        local fname = vim.api.nvim_buf_get_name(bufnr)
        local root_markers = util.insert_package_json({ ".oxlintrc.json" }, "oxlint", fname)
        on_dir(vim.fs.dirname(vim.fs.find(root_markers, { path = fname, upward = true })[1]))
    end,
}
