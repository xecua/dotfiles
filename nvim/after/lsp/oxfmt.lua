return {
    cmd = function(dispatchers, config)
        local cmd = "oxfmt"
        local local_cmd = (config or {}).root_dir and config.root_dir .. "/node_modules/.bin/oxfmt"
        if local_cmd and vim.fn.executable(local_cmd) == 1 then
            cmd = local_cmd
        end
        return vim.lsp.rpc.start({ cmd, "--lsp" }, dispatchers)
    end,
    workspace_required = true,
    root_dir = function(bufnr, on_dir)
        if vim.fs.root(bufnr, { "deno.json", "deno.jsonc", "deno.lock" }) then
            -- deno fmt使うやろ
            return
        end

        on_dir(vim.fs.root(bufnr, { ".oxfmtrc.json", ".oxfmtrc.jsonc" }))
    end,
}
