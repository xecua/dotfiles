-- null-ls: LSP interface for linter/formatter
-- preferred (via Mason?): stylua, yapf, prettier
-- note: null-ls' `builtins` are just a configuration, and binaries must be installed by hand (so Mason is good choice): https://github.com/williamboman/mason.nvim/discussions/143
local null_ls = require("null-ls")

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
      })
    end

    if client.server_capabilities.documentRangeFormattingProvider then
      -- in visual mode automatically set to range?
      vim.keymap.set("v", "<Leader>if", vim.lsp.buf.format, {
        buffer = bufnr,
        silent = true,
      })
    end

    vim.api.nvim_buf_create_user_command(bufnr, 'Format', vim.lsp.buf.format, {})
  end,
})

-- null-ls config wrapper for prettier
local prettier = require("prettier")
prettier.setup({
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
