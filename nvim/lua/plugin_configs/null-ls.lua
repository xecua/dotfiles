-- null-ls: LSP interface for linter/formatter
-- note: `builtins` are just a (builtin) configuration, and executables must be installed separately (Mason is a good choice)
local null_ls = require("null-ls")

-- local ensure_installed = {
--   "stylua", "yapf", "prettier"
-- }

null_ls.setup({
  sources = {
    null_ls.builtins.formatting.stylua.with({
      extra_args = { "--indent-type", "Spaces", "--indent-width", "2" },
    }),
    null_ls.builtins.formatting.yapf,
  },
  on_attach = function(client, bufnr)
    if client.server_capabilities.documentFormattingProvider then
      vim.keymap.set("n", "<Leader>if", vim.lsp.buf.format, {
        buffer = bufnr,
        silent = true,
        desc = "null-ls: Format whole file",
      })
    end

    if client.server_capabilities.documentRangeFormattingProvider then
      -- in visual mode automatically set to range?
      vim.keymap.set("v", "<Leader>if", vim.lsp.buf.format, {
        buffer = bufnr,
        silent = true,
        desc = "null-ls: Format selected range",
      })
    end

    vim.api.nvim_buf_create_user_command(bufnr, "Format", vim.lsp.buf.format, {})
  end,
})

-- null-ls config wrapper for prettier
require("prettier").setup({
  bin = "prettier", -- or `prettierd`
  filetypes = {
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
