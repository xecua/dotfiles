return {
    init_options = {
        preferences = {
            includeCompletionsWithInsertText = false,
        },
    },
    cmd = function(dispatchers, config)
        local cmd = "tsgo"
        local local_tsc = config.root_dir .. "/node_modules/.bin/tsc"
        local local_tsgo = config.root_dir .. "/node_modules/.bin/tsgo"
        if
            vim.fn.executable(local_tsc) == 1
            and (vim.system({ local_tsc, "--version" }, { text = true }):wait().stdout or ""):match("^Version 7")
        then
            cmd = local_tsc
            goto execute
        end
        if vim.fn.executable(local_tsgo) == 1 then
            cmd = local_tsgo
            goto execute
        end
        if
            vim.fn.executable("tsc") == 1
            and (vim.system({ "tsc", "--version" }, { text = true }):wait().stdout or ""):match("^Version 7")
        then
            cmd = "tsc"
            goto execute
        end
        ::execute::
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
