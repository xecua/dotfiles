local ok, fs = pcall(require, "efmls-configs.fs")
if not ok then
    return {}
end

local phpcs = require("efmls-configs.linters.phpcs")
phpcs.lintCommand = string.format(
    ' %s --no-colors --exclude=Generic.Files.LineLength --report=emacs --stdin-path="${INPUT}" -',
    fs.executable("phpcs", fs.Scope.COMPOSER)
)

local prettier = require("efmls-configs.formatters.prettier")
prettier.rootMarkers = {
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
}
prettier.requireMarker = true

local languages = {
    html = { prettier },
    css = { prettier },
    sass = { prettier },
    scss = { prettier },
    less = { prettier },
    javascript = { prettier },
    javascriptreact = { prettier },
    json = { prettier },
    jsonc = { prettier },
    json5 = { prettier },
    ["json.openapi"] = { prettier },
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
