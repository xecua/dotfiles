local prettier = require("efmls-configs.formatters.prettier")
local languages = {
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
        require("efmls-configs.formatters.stylua"),
    },
    php = {
        require("efmls-configs.linters.phpcs"),
        require("efmls-configs.formatters.phpcbf"),
    },
    python = {
        require("efmls-configs.formatters.yapf"),
    },
    sql = {
        require("efmls-configs.formatters.sql-formatter"),
    },
}

return {
    filetypes = vim.tbl_keys(languages),
    init_options = {
        documentFormatting = true,
        documentRangeFormatting = true,
    },
    settings = { languages = languages },
}
