return {
    init_options = {
        preferences = {
            includeCompletionsWithInsertText = false,
        },
    },
    workspace_required = true,
    root_dir = function(bufnr, on_dir)
        -- Give the root markers equal priority by wrapping them in a table
        local root_markers = { "package-lock.json", "yarn.lock", "pnpm-lock.yaml", "bun.lockb", "bun.lock" }
        root_markers = vim.fn.has("nvim-0.11.3") == 1 and { root_markers, { ".git" } }
            or vim.list_extend(root_markers, { ".git" })
        if vim.fs.root(bufnr, { "deno.json", "deno.jsonc", "deno.lock" }) then
            return
        end

        on_dir(vim.fs.root(bufnr, root_markers))
    end,
}
