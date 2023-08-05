local efmls = require("efmls-configs")

efmls.init({
  init_options = {
    documentFormatting = true
  }
})

-- formatters/linters used multiple times
local stylelint = require("efmls-configs.linters.stylelint")
-- eslint: lsp版使ってた
-- local eslint = require("efmls-configs.linters.eslint")
local prettier = require("efmls-configs.formatters.prettier_d")

efmls.setup({
  html = { linter = stylelint, formatter = prettier },
  css = { linter = stylelint, formatter = prettier },
  sass = { linter = stylelint, formatter = prettier },
  scss = { linter = stylelint, formatter = prettier },
  less = { linter = stylelint, formatter = prettier },
  javascript = { formatter = prettier },
  javascriptreact = { formatter = prettier },
  typescript = { formatter = prettier },
  typescriptreact = { formatter = prettier },
  go = {
    linter = require('efmls-configs.linters.golangci_lint')
  },
  lua = {
    linter = require('efmls-configs.linters.luacheck'),
    formatter = require('efmls-configs.formatters.stylua'),
  },
  php = {
    linter = require('efmls-configs.linters.phpcs'),
    formatter = require('efmls-configs.formatters.phpcbf'),
  },
  python = {
    formatter = require('efmls-configs.formatters.yapf'),
    -- (pyrightがそこそこやってくれる説ないか?)
    -- linters = require("efmls-configs.linters.flake8")
  },
  ruby = {
    linter = require('efmls-configs.linters.reek'),
  },
  vim = {
    linter = require('efmls-configs.linters.vint'),
  },
})
