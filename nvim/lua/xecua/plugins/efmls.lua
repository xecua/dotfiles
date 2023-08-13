local efmls = require("efmls-configs")

local prettier = require("efmls-configs.formatters.prettier_d")
local stylua = vim.tbl_extend("force", require("efmls-configs.formatters.stylua"), {
  formatCommand = string.format(
    "%s ${--indent-width:tabSize} ${--range-start:charStart} ${--range-end:charEnd} --color Never --quote-style AutoPreferSingle -",
    -- インデントスタイルの設定はefmでは現状不可なので.editorconfigで。PR投げる?
    require("efmls-configs.fs").executable("stylua")
  ),
  rootMarkers = { "stylua.toml", ".stylua.toml", ".editorconfig" },
})

efmls.init({
  init_options = {
    documentFormatting = true,
  },
})

efmls.setup({
  html = { formatter = prettier },
  css = { formatter = prettier },
  sass = { formatter = prettier },
  scss = { formatter = prettier },
  less = { formatter = prettier },
  javascript = { formatter = prettier },
  javascriptreact = { formatter = prettier },
  json = { formatter = prettier },
  markdown = { formatter = prettier },
  typescript = { formatter = prettier },
  typescriptreact = { formatter = prettier },
  vue = { formatter = prettier },
  go = {
    linter = require("efmls-configs.linters.golangci_lint"),
  },
  lua = {
    linter = require("efmls-configs.linters.luacheck"),
    formatter = stylua,
  },
  php = {
    linter = require("efmls-configs.linters.phpcs"),
    formatter = require("efmls-configs.formatters.phpcbf"),
  },
  python = {
    formatter = require("efmls-configs.formatters.yapf"),
    -- (pyrightがそこそこやってくれる説ないか?)
    -- linters = require("efmls-configs.linters.flake8")
  },
  ruby = {
    linter = require("efmls-configs.linters.reek"),
  },
  vim = {
    linter = require("efmls-configs.linters.vint"),
  },
})
