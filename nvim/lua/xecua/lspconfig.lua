local utils = require("xecua.utils")

local M = {}

-- wrapper: https://zenn.dev/ryoppippi/articles/8aeedded34c914
local augroup = vim.api.nvim_create_augroup("LspConfig", {})
M.on_attach = function(callback)
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      local buffer = args.buf
      callback(client, buffer)
    end,
  })
end

-- common
M.on_attach(function(client, buffer)
  -- Enable completion triggered by <c-x><c-o>
  -- buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts_with_desc = function(desc)
    return { buffer = buffer, silent = true, desc = "LSP: " .. desc }
  end

  -- LSP related: preceded by <Leader>i
  vim.keymap.set("n", "<Leader>id", vim.lsp.buf.definition, opts_with_desc("Definition"))
  vim.keymap.set("n", "<Leader>it", vim.lsp.buf.type_definition, opts_with_desc("Type definition"))
  vim.keymap.set("n", "<Leader>ii", vim.lsp.buf.implementation, opts_with_desc("Implementation"))
  vim.keymap.set("n", "<Leader>ir", vim.lsp.buf.references, opts_with_desc("References"))
  vim.keymap.set("n", "<Leader>i]", vim.diagnostic.goto_next, opts_with_desc("Goto next item"))
  vim.keymap.set("n", "<Leader>i[", vim.diagnostic.goto_prev, opts_with_desc("Goto previous item"))
  vim.keymap.set("n", "<Leader>ia", vim.lsp.buf.code_action, opts_with_desc("Code actions"))
  vim.keymap.set("n", "<Leader>im", vim.lsp.buf.hover, opts_with_desc("Hover"))

  vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, opts_with_desc("Rename"))

  local format_opts = {
    bufnr = buffer,
    filter = function(clt)
      return utils.find(clt.name, {
        "tsserver",
        "jsonls",
        "lua_ls",
        "pyright",
        "html",
      }) == -1
    end,
  }

  if client.server_capabilities.documentFormattingProvider then
    vim.keymap.set("n", "<Leader>if", function()
      vim.lsp.buf.format(format_opts)
    end, opts_with_desc("Format whole file"))

    vim.api.nvim_create_autocmd("BufWritePre", {
      group = augroup,
      buffer = buffer,
      callback = function()
        vim.lsp.buf.format(format_opts)
      end,
      desc = "LSP: Format on save",
    })
  end

  if client.server_capabilities.documentRangeFormattingProvider then
    vim.keymap.set("v", "<Leader>if", function()
      vim.lsp.buf.format(format_opts)
    end, opts_with_desc("Format selected range"))
  end

  vim.api.nvim_buf_create_user_command(buffer, "Format", function()
    vim.lsp.buf.format(format_opts)
  end, { desc = "LSP: Format whole file" })
end)

return M
