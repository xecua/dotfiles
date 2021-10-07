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


    jdtls.start_or_attach({
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
