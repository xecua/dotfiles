local fs = require("efmls-configs.fs")

local phpcs = require("efmls-configs.linters.phpcs")
phpcs.lintCommand = string.format(
    ' %s --no-colors --exclude=Generic.Files.LineLength --report=emacs --stdin-path="${INPUT}" -',
    fs.executable("phpcs", fs.Scope.COMPOSER)
)

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
    typescript = { prettier },
    typescriptreact = { prettier },
    yaml = { prettier },
    ["yaml.openapi"] = { prettier },
    ["yaml.compose"] = { prettier },
    vue = { prettier },
    go = {
        require("efmls-configs.linters.golangci_lint"),
    },
    lua = {
        require("efmls-configs.linters.luacheck"),
        require("efmls-configs.formatters.stylua"),
    },
    php = {
        phpcs,
        -- require("efmls-configs.formatters.phpcbf"),
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
