-- null-ls: LSP interface for linter/formatter
-- note: `builtins` are just a (builtin) configuration, and executables must be installed separately (Mason is a good choice)
local null_ls = require("null-ls")
local augroup = vim.api.nvim_create_augroup("NullLs", {})

-- local ensure_installed = {
--   "stylua", "yapf", "prettier", "textlint"
-- }

null_ls.setup({
  sources = {
    null_ls.builtins.formatting.stylua.with({
      extra_args = { "--indent-type", "Spaces", "--indent-width", "2" },
    }),
    null_ls.builtins.formatting.yapf,
    null_ls.builtins.formatting.textlint,
    -- causes 'failed to decode json error'
    -- null_ls.builtins.diagnostics.textlint,
  },
  on_attach = function(client, bufnr)
    local format_opts = { bufnr = bufnr }

    if client.server_capabilities.documentFormattingProvider then
      vim.keymap.set("n", "<Leader>if", function()
        vim.lsp.buf.format(format_opts)
      end, {
        buffer = bufnr,
        silent = true,
        desc = "null-ls: Format whole file",
      })

      vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format(format_opts)
        end,
        desc = "null-ls: Format on save",
      })
    end

    if client.server_capabilities.documentRangeFormattingProvider then
      -- in visual mode automatically set to range?
      vim.keymap.set("v", "<Leader>if", function()
        vim.lsp.buf.format(format_opts)
      end, {
        buffer = bufnr,
        silent = true,
        desc = "null-ls: Format selected range",
      })
    end

    vim.api.nvim_buf_create_user_command(bufnr, "Format", function()
      vim.lsp.buf.format(format_opts)
    end, { desc = "null-ls: Format whole file" })
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
