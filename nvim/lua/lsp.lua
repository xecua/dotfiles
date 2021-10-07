local lsp_config = require('lspconfig')
local servers = { 'pyright', 'rust_analyzer', 'clangd', 'tsserver', 'vimls', 'html', 'texlab', 'gopls' }

local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- Enable completion triggered by <c-x><c-o>
  -- buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true }

  buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'gy', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', ']g', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '[g', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<leader>i', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('n', '<leader>m', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('x', '<leader>f', '<cmd>lua vim.lsp.buf.range_formatting(vim.lsp.buf.make_given_range_params().range["start"], vim.lsp.buf.make_given_range_params().range["end"])<CR>', opts)

end

local commands = {
    Format = {
        function() vim.lsp.buf.formatting() end
    }
}

for _, server in ipairs(servers) do
    lsp_config[server].setup({
        on_attach = on_attach,
        commands = commands
    })
end

-- extra configuration
lsp_config.jsonls.setup({
    on_attach = on_attach,
    commands = {
        Format = {
            function() vim.lsp.buf.range_formatting({}, {0, 0}, {vim.fn.line("$"), 0}) end
        }
    }
})
