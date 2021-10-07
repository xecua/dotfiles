if vim.fn.has('nvim-0.5') == 1 then
    local jdtls = require('jdtls')
    local os = vim.api.nvim_get_var('os')

    local jdt_home = vim.env.HOME .. '/.local/lib/jdt'
    local launcher_jar = jdt_home .. '/plugins/org.eclipse.equinox.launcher_1.6.300.v20210813-1054.jar'
    local workspace_dirname = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')

    local configuration
    if os == 'Linux' then
        configuration = jdt_home .. '/config_linux'
    elseif os == 'Windows' then
        configuration = jdt_home .. '/config_win'
    elseif os == 'Darwin' then
        configuraiton = jdt_home .. '/config_mac'
    end

    -- lua/lsp.luaと同じ。なんとかしたいね
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

    jdtls.start_or_attach({
        on_attach = on_attach,
        cmd = {
            'java',
            '-Dosgi.bundles.defaultStartLevel=4',
            '-Declipse.application=org.eclipse.jdt.ls.core.id1',
            '-Declipse.product=org.eclipse.jdt.ls.core.product',
            '-Dlog.level=ALL',
            '-noverify',
            '-Xmx1G',
            '-jar',
            launcher_jar,
            '-configuration',
            configuration,
            '-data',
            vim.env.HOME .. '/jdt/' .. workspace_dirname,
            '--add-modules=ALL-SYSTEM',
            '--add-opens java.base/java.util=ALL-UNNAMED',
            '--add-opens java.base/java.lang=ALL-UNNAMED'
        }
    })

end
