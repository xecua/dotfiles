local prettier = vim.tbl_extend("force", require("efmls-configs.formatters.prettier"), {
    requireMarker = true,
})
local deno_fmt = vim.tbl_extend("force", require("efmls-configs.formatters.deno_fmt"), {
    requireMarker = true,
    rootMarkers = { "deno.json", "deno.jsonc" },
})
local stylua = vim.tbl_extend("force", require("efmls-configs.formatters.stylua"), {
    formatCommand = string.format(
        "%s ${--indent-width:tabSize} ${--range-start:charStart} ${--range-end:charEnd} --color Never --quote-style AutoPreferSingle -",
        -- インデントスタイルの設定はefmでは現状不可なので.editorconfigで。PR投げる?
        require("efmls-configs.fs").executable("stylua")
    ),
    rootMarkers = { "stylua.toml", ".stylua.toml", ".editorconfig" },
})

return {
    html = { prettier },
    css = { prettier },
    sass = { prettier },
    scss = { prettier },
    less = { prettier },
    javascript = { prettier, deno_fmt },
    javascriptreact = { prettier, deno_fmt },
    json = { prettier, deno_fmt },
    markdown = { prettier, deno_fmt },
    typescript = { prettier, deno_fmt },
    typescriptreact = { prettier, deno_fmt },
    yaml = { prettier },
    vue = { prettier },
    go = {
        require("efmls-configs.linters.golangci_lint"),
    },
    lua = {
        require("efmls-configs.linters.luacheck"),
        stylua,
    },
    php = {
        require("efmls-configs.linters.phpcs"),
        require("efmls-configs.formatters.phpcbf"),
    },
    python = {
        require("efmls-configs.formatters.yapf"),
    },
}
