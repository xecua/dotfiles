--- lua_source {{{
-- efmls-configs の各モジュールは require 時に executable() / exepath() (golangci_lint は外部コマンドも) を呼ぶ。
-- Windows だと 1 つ 40ms ほどかかるので、efm を起動するときまで require を遅らせる。

local function prettier()
    return vim.tbl_extend("force", require("efmls-configs.formatters.prettier"), {
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
end

local function load(name)
    return function()
        return require("efmls-configs." .. name)
    end
end

--- filetype -> tool 設定を返す関数のリスト
local tools = {
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
    go = { load("linters.golangci_lint") },
    lua = { load("linters.luacheck") },
    php = { load("formatters.php_cs_fixer"), load("linters.phpstan") },
    sql = { load("formatters.sql-formatter") },
}

local languages
local function build_languages()
    if languages == nil then
        languages = {}
        local cache = {}
        for ft, fns in pairs(tools) do
            languages[ft] = vim.tbl_map(function(fn)
                cache[fn] = cache[fn] or fn()
                return cache[fn]
            end, fns)
        end
    end
    return languages
end

vim.lsp.config("efm", {
    filetypes = vim.tbl_keys(tools),
    init_options = {
        documentFormatting = true,
        documentRangeFormatting = true,
        documentSymbol = false,
        completion = false,
        codeAction = false,
        hover = false,
    },
    settings = {},
    before_init = function(_, config)
        -- settingsを動的に生成 (efmls-configs の require を遅延させて起動を速くする)
        config.settings.languages = build_languages()
    end,
})

vim.lsp.enable("efm")

--- }}}
