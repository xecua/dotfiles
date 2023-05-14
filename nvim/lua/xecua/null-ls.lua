-- null-ls: LSP interface for linter/formatter
-- note: `builtins` are just a (builtin) configuration, and executables must be installed separately (Mason is a good choice)
local null_ls = require("null-ls")
-- local augroup = vim.api.nvim_create_augroup("NullLs", {})

-- local ensure_installed = {
--   "stylua", "yapf", "prettier", "textlint"
-- }

-- これlspだとprettier.nvimのnull_lsが読まれて怒られてる
null_ls.setup({
  sources = {
    null_ls.builtins.formatting.stylua.with({
      extra_args = { "--indent-type", "Spaces", "--indent-width", "2" },
    }),
    null_ls.builtins.formatting.yapf,
    -- null_ls.builtins.formatting.textlint,
    -- null_ls.builtins.diagnostics.textlint, -- causes 'failed to decode json error'
  },
})

-- null-ls config wrapper for prettier
require("prettier").setup({
  bin = "prettierd",
  filetypes = require("xecua.lspconfig").prettier_filetypes,
})
