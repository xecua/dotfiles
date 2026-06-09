--- lua_source {{{
local prettier = vim.tbl_extend("force", require("efmls-configs.formatters.prettier"), {
    rootMarkers = {
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
    },
    requireMarker = true,
})

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
    },
    php = {
        require("efmls-configs.formatters.php_cs_fixer"),
        require("efmls-configs.linters.phpstan"),
    },
    sql = {
        require("efmls-configs.formatters.sql-formatter"),
    },
}

vim.lsp.config("efm", {
    filetypes = vim.tbl_keys(languages),
    init_options = {
        documentFormatting = true,
        documentRangeFormatting = true,
        documentSymbol = false,
        completion = false,
        codeAction = false,
        hover = false,
    },
    settings = { languages = languages },
    capabilities = {
        textDocument = {
            documentSymbol = false,
            completion = false,
            codeAction = false,
            hover = false,
        },
    },
})

vim.lsp.enable("efm")

--- }}}
