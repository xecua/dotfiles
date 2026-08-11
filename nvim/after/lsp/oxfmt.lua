return {
    cmd = function(dispatchers, config)
        local cmd = "oxfmt"
        local local_cmd = config.root_dir .. "/node_modules/.bin/oxfmt"
        if local_cmd and vim.fn.executable(local_cmd) == 1 then
            cmd = local_cmd
        end
        return vim.lsp.rpc.start({ cmd, "--lsp" }, dispatchers)
    end,
    workspace_required = false,
    root_dir = function(bufnr, on_dir)
        if vim.fs.root(bufnr, { "deno.json", "deno.jsonc", "deno.lock" }) then
            -- deno fmt使うやろ
            return
        end
        if
            vim.fs.root(bufnr, {
                ".prettierrc",
                ".prettierrc.json",
                ".prettierrc.yml",
                ".prettierrc.yaml",
                ".prettierrc.json5",
                ".prettierrc.js",
                "prettier.config.js",
                ".prettierrc.ts",
                "prettier.config.ts",
                ".prettierrc.mjs",
                "prettier.config.mjs",
                ".prettierrc.mts",
                "prettier.config.mts",
                ".prettierrc.cjs",
                "prettier.config.cjs",
                "prettier.config.cts",
                ".prettierrc.cts",
                ".prettierrc.toml",
            })
        then
            -- prettier使うやろ
            return
        end

        local fname = vim.api.nvim_buf_get_name(bufnr)
        local util = require("lspconfig.util")

        -- Oxfmt resolves configuration by walking upward and using the nearest config file
        -- to the file being processed. We therefore compute the root directory by locating
        -- the closest `.oxfmtrc.json` / `.oxfmtrc.jsonc` / `oxfmt.config.ts` (or `package.json` fallback) above the buffer.
        local root_markers = util.insert_package_json(
            { ".oxfmtrc.json", ".oxfmtrc.jsonc", "oxfmt.config.ts" },
            { "oxfmt", "vite%-plus" },
            fname
        )
        -- find vite plus config with fmt field
        root_markers = util.root_markers_with_field(
            root_markers,
            { "vite.config.ts" },
            { "vite%-plus", "fmt:" },
            fname,
            "all"
        )
        on_dir(vim.fs.root(bufnr, root_markers) or vim.fn.getcwd())
    end,
}
