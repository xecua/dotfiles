local List = require("plenary.collections.py_list")

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

M.prettier_filetypes = List({
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
})
local formatter_disabled_client_names = M.prettier_filetypes:concat({
  "lua_ls",
  "pyright",
})

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
  vim.keymap.set("n", "<Leader>ici", vim.lsp.buf.incoming_calls, opts_with_desc("Incoming calls"))
  vim.keymap.set("n", "<Leader>ico", vim.lsp.buf.outgoing_calls, opts_with_desc("Outgoing calls"))
  vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, opts_with_desc("Rename"))

  if not formatter_disabled_client_names:contains(client.name) then
    vim.keymap.set({ "n", "v" }, "<Leader>if", vim.lsp.buf.format, opts_with_desc("Format"))
    vim.api.nvim_buf_create_user_command(buffer, "Format", function()
      vim.lsp.buf.format()
    end, { desc = "LSP: Format whole file" })
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = augroup,
      buffer = buffer,
      callback = function()
        vim.lsp.buf.format()
      end,
      desc = "LSP: Format on save",
    })
  end
  if client.name == "eslint" then
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = augroup,
      buffer = buffer,
      command = "EslintFixAll",
    })
  end
  if client.name == "rust_analyzer" then
    vim.keymap.set(
      "n",
      "<Leader>ih",
      require("rust-tools").hover_actions.hover_actions,
      { buffer = buffer, silent = true, desc = "LSP: Hover with actions" }
    )
    vim.keymap.set(
      "n",
      "<Leader>ia",
      require("rust-tools").code_action_group.code_action_group,
      { buffer = buffer, silent = true, desc = "LSP: Code action" }
    )
  end
  if client.name == "jdtls" then
    local jdtls = require("jdtls")
    vim.keymap.set(
      "n",
      "<Leader>io",
      jdtls.organize_imports,
      { buffer = buffer, silent = true, desc = "LSP: Organize imports" }
    )
    vim.keymap.set("n", "<Leader>dc", jdtls.test_class, { buffer = buffer, silent = true, desc = "LSP: Test class" })
    vim.keymap.set(
      "n",
      "<Leader>dm",
      jdtls.test_nearest_method,
      { buffer = buffer, silent = true, desc = "LSP: Test nearest method" }
    )
    jdtls.setup_dap({ hotcodereplace = "auto" })
    require("jdtls.setup").add_commands()
  end

  local is_hovering = false
  vim.keymap.set("n", "<Leader>ih", function()
    is_hovering = true
    vim.lsp.buf.signature_help()
  end, opts_with_desc("Signature Help"))
  vim.keymap.set("n", "<Leader>im", function()
    is_hovering = true
    vim.lsp.buf.hover()
  end, opts_with_desc("Hover"))
  vim.api.nvim_create_autocmd("CursorHoldI", {
    group = augroup,
    buffer = buffer,
    callback = function()
      if not is_hovering then
        if client.server_capabilities.hoverProvider then
          vim.lsp.buf.hover()
        end
        if client.server_capabilities.signatureHelpProvider then
          vim.lsp.buf.signature_help()
        end
      end
    end,
    desc = "LSP: Signature Help on Hold",
  })
  vim.api.nvim_create_autocmd("CursorMovedI", {
    group = augroup,
    buffer = buffer,
    callback = function()
      is_hovering = false
    end,
  })
end)

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = "single",
  focusable = false,
  silent = true,
})
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
  border = "single",
  focusable = false,
  silent = true,
})

return M
