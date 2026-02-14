return {
    filetypes = {
        "javascript",
        "javascriptreact",
        "javascript.jsx",
        "typescript",
        "typescriptreact",
        "typescript.tsx",
        "markdown",
        "json",
        "jsonc",
        "css",
        "html",
        "yaml",
        "sass",
        "scss",
        "less",
        -- experimental (enabled by deno.unstable)
        "astro",
        "vue",
        "sql",
        "svelte",
    },
    settings = {
        deno = { unstable = { "fmt-component" } },
    },
    workspace_required = true,
    root_dir = function(bufnr, on_dir)
        on_dir(vim.fs.root(bufnr, { "deno.json", "deno.jsonc", "deno.lock" }))
    end,
}
