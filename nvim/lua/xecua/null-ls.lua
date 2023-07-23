-- null-ls: LSP interface for linter/formatter
-- note: `builtins` are just a (builtin) configuration, and executables must be installed separately (Mason is a good choice)
local null_ls = require("null-ls")
-- local augroup = vim.api.nvim_create_augroup("NullLs", {})

-- local ensure_installed = {
--   "stylua", "yapf", "prettierd"
-- }

-- これlspだとprettier.nvimのnull_lsが読まれて怒られてる
null_ls.setup({
  sources = {
    null_ls.builtins.formatting.yapf,
    -- null_ls.builtins.formatting.textlint,
    -- null_ls.builtins.diagnostics.textlint, -- causes 'failed to decode json error'
  },
})

-- null-ls config wrapper for prettier
require("prettier").setup({
  bin = "prettierd",
  filetypes = {
    "astro",
    "css",
    "graphql",
    "html",
    "javascript",
    "javascript.jsx",
    "javascriptreact",
    "json",
    "less",
    "markdown",
    "sss",
    "typescript",
    "typescript.tsx",
    "typescriptreact",
    "yaml",
  },
})
