return {
    init_options = {
        preferences = {
            includeCompletionsWithInsertText = false,
        },
    },
    cmd = function(dispatchers, config)
        local cmd = "tsc"
        local local_cmd = config.root_dir .. "/node_modules/.bin/tsc"

        if
            vim.fn.executable(local_cmd) == 1
            and (vim.system({ local_cmd, "--version" }, { text = true }):wait().stdout or ""):match("^Version 7")
        then
            cmd = local_cmd
        end
        return vim.lsp.rpc.start({ cmd, "--lsp", "--stdio" }, dispatchers)
    end,
    workspace_required = true,
    root_dir = function(bufnr, on_dir)
        -- Give the root markers equal priority by wrapping them in a table
        local root_markers = {
            "package-lock.json",
            "yarn.lock",
            "pnpm-lock.yaml",
            "bun.lockb",
            "bun.lock",
        }
        root_markers = { root_markers, { ".git" } }
        if vim.fs.root(bufnr, { "deno.json", "deno.jsonc", "deno.lock" }) then
            return
        end

        on_dir(vim.fs.root(bufnr, root_markers))
    end,
}
