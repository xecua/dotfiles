local prettier = vim.tbl_extend("force", require("efmls-configs.formatters.prettier"), {
    requireMarker = true,
})
local stylua = vim.tbl_extend("force", require("efmls-configs.formatters.stylua"), {
    -- これいらんか
    -- formatCommand = string.format(
    --     '%s ${--indent-width:tabSize} ${--range-start:charStart} ${--range-end:charEnd} --color Never --quote-style AutoPreferSingle -',
    --     -- インデントスタイルの設定はefmでは現状不可なので.editorconfigで。PR投げる?
    --     require('efmls-configs.fs').executable('stylua')
    -- ),
    rootMarkers = { "stylua.toml", ".stylua.toml", ".editorconfig" },
})

return {
    html = { prettier },
    css = { prettier },
    sass = { prettier },
    scss = { prettier },
    less = { prettier },
    javascript = { prettier },
    javascriptreact = { prettier },
    json = { prettier },
    markdown = { prettier },
    typescript = { prettier },
    typescriptreact = { prettier },
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
