<<<<<<< HEAD
-- lua_post_source {{{
=======
>>>>>>> d2ceb59 (make state)
local M = {}
local nlspsettings = require('nlspsettings')

-- wrapper: https://zenn.dev/ryoppippi/articles/8aeedded34c914
local augroup = vim.api.nvim_create_augroup('LspConfig', {})
M.on_attach = function(callback)
  vim.api.nvim_create_autocmd('LspAttach', {
    group = augroup,
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
  local is_hovering = false

  -- commands
  vim.api.nvim_buf_create_user_command(buffer, 'LspFormat', 'lua vim.lsp.buf.format()', {})
  vim.api.nvim_buf_create_user_command(buffer, 'LspSignatureHelp', function()
    is_hovering = true
    vim.lsp.buf.signature_help()
  end, {})
  vim.api.nvim_buf_create_user_command(buffer, 'LspHover', function()
    is_hovering = true
    vim.lsp.buf.hover()
  end, {})
  vim.api.nvim_buf_create_user_command(buffer, 'LspReferences', 'lua vim.lsp.buf.references()', {})
  vim.api.nvim_buf_create_user_command(buffer, 'LspDefinition', 'lua vim.lsp.buf.definition()', {})
  vim.api.nvim_buf_create_user_command(buffer, 'LspTypeDefinition', 'lua vim.lsp.buf.type_definition()', {})
  vim.api.nvim_buf_create_user_command(buffer, 'LspImplementation', 'lua vim.lsp.buf.implementation()', {})
  vim.api.nvim_buf_create_user_command(buffer, 'LspCodeAction', 'lua vim.lsp.buf.code_action()', {})
  vim.api.nvim_buf_create_user_command(buffer, 'LspIncomingCalls', 'lua vim.lsp.buf.incoming_calls()', {})
  vim.api.nvim_buf_create_user_command(buffer, 'LspOutgoingCalls', 'lua vim.lsp.buf.outgoing_calls()', {})
  vim.api.nvim_buf_create_user_command(buffer, 'LspRename', 'lua vim.lsp.buf.rename()', {})
  vim.api.nvim_buf_create_user_command(buffer, 'LspNext', 'lua vim.diagnostic.goto_next()', {})
  vim.api.nvim_buf_create_user_command(buffer, 'LspPrev', 'lua vim.diagnostic.goto_prev()', {})

  -- Mappings.
  local opts = { buffer = buffer, silent = true }

  -- LSP related: preceded by <Leader>i
  vim.keymap.set({ 'n', 'v' }, '<Leader>if', '<Cmd>LspFormat<CR>', opts)
  vim.keymap.set('n', '<Leader>ih', '<Cmd>LspSignatureHelp<CR>', opts)
  vim.keymap.set('n', '<Leader>im', '<Cmd>LspHover<CR>', opts)
  vim.keymap.set('n', '<Leader>ir', '<Cmd>LspReferences<CR>', opts)
  vim.keymap.set('n', '<Leader>id', '<Cmd>LspDefinition<CR>', opts)
  vim.keymap.set('n', '<Leader>it', '<Cmd>LspTypeDefinition<CR>', opts)
  vim.keymap.set('n', '<Leader>ii', '<Cmd>LspImplementation<CR>', opts)
  vim.keymap.set('n', '<Leader>i]', '<Cmd>LspNext<CR>', opts)
  vim.keymap.set('n', '<Leader>i[', '<Cmd>LspPrev<CR>', opts)
  vim.keymap.set('n', '<Leader>ia', '<Cmd>LspCodeAction<CR>', opts)
  vim.keymap.set('n', '<Leader>ici', '<Cmd>LspIncomingCalls<CR>', opts)
  vim.keymap.set('n', '<Leader>ico', '<Cmd>LspOutgoingCalls<CR>', opts)
  vim.keymap.set('n', '<F2>', '<Cmd>LspRename<CR>', opts)

  if client.name == 'tsserver' then
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end
  if client.name == 'rust_analyzer' then
    vim.api.nvim_buf_create_user_command(
      buffer,
      'LspHoverActions',
      'lua require("rust-tools").hover_actions.hover_actions()',
      {}
    )
    vim.keymap.set('n', '<Leader>ih', '<Cmd>LspHoverActions<CR>', { buffer = buffer, silent = true })
    vim.api.nvim_buf_create_user_command(
      buffer,
      'LspCodeAction',
      'lua require("rust-tools").code_action_group.code_action_group()',
      { force = true }
    )
  end
  if client.name == 'jdtls' then
    vim.api.nvim_buf_create_user_command(buffer, 'LspOrganizeImports', 'lua require("jdtls").organize_imports()', {})
    vim.keymap.set('n', '<Leader>io', '<Cmd>LspOrganizeImports<CR>', { buffer = buffer, silent = true })

    vim.api.nvim_buf_create_user_command(buffer, 'LspTestClass', 'lua require("jdtls").test_class()', {})
    vim.keymap.set('n', '<Leader>dc', '<Cmd>LspTestClass<CR>', { buffer = buffer, silent = true })

    vim.api.nvim_buf_create_user_command(buffer, 'LspTestMethod', 'lua require("jdtls").test_nearest_method()', {})
    vim.keymap.set('n', '<Leader>dm', '<Cmd>LspTestMethod<CR>', { buffer = buffer, silent = true })

    require('jdtls').setup_dap({ hotcodereplace = 'auto' })
  end

  if client.server_capabilities.documentFormattingProvider then
    vim.api.nvim_create_autocmd('BufWritePre', {
      group = augroup,
      buffer = buffer,
      callback = function()
        vim.lsp.buf.format()
      end,
      desc = 'LSP: Format on save',
    })
  end

  if client.server_capabilities.hoverProvider then
    vim.api.nvim_create_autocmd('CursorHoldI', {
      group = augroup,
      buffer = buffer,
      callback = function()
        if not is_hovering then
          vim.lsp.buf.hover()
        end
      end,
      desc = 'LSP: Signature Help on Hold',
    })
    vim.api.nvim_create_autocmd('CursorMovedI', {
      group = augroup,
      buffer = buffer,
      callback = function()
        is_hovering = false
      end,
    })
  end
end)

vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = 'single',
  focusable = false,
  silent = true,
})
vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, {
  border = 'single',
  focusable = false,
  silent = true,
})

return M
-- }}}
