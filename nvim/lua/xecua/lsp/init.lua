-- vim.lsp.config('*', {})

vim.lsp.config("denols", require("xecua.lsp.denols"))
vim.lsp.config("intelephense", require("xecua.lsp.intelephense"))
vim.lsp.config("jsonls", require("xecua.lsp.lua_ls"))
vim.lsp.config("texlab", require("xecua.lsp.texlab"))

vim.lsp.enable({
    -- "denols",
    -- "eslint",
    "intelephense",
    "lua_ls",
    "texlab",
    "jsonls",
    -- "efm",

    "sourcekit",
    "nil_ls",
    -- "astro",
    "pyright",
    "clangd",
    "vimls",
    "html",
    "gopls",
    "kotlin_language_server",
    "tsp_server",
    "stylelint_lsp",
    "sqls",
    "lemminx",
    "yamlls",
    "taplo",
    -- "typos_lsp",
})

local augroup = vim.api.nvim_create_augroup("Lsp", {})
-- workaround until workspace_required become available
vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = { "typescript", "typescriptreact" },
    group = augroup,
    callback = function()
        if vim.fs.root(0, vim.lsp.config["denols"].root_markers) ~= nil then
            vim.lsp.start(vim.lsp.config["denols"])
        end
    end,
})
vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = { "java" },
    group = augroup,
    callback = function()
        require("jdtls").start_or_attach({ cmd = "jdtls" })
        --[[
        -- setting up jdtls (this does not work when called in setup_handlers)
        local registry = require("mason-registry")
        local pkg_dir = registry.get_package("jdtls"):get_install_path()
        local jdtls = require("jdtls")
        local jar_path = vim.fn.glob(pkg_dir .. "/plugins/org.eclipse.equinox.launcher_*.jar")
        local system = "linux"
        if vim.g.os == "Windows" then
            system = "win"
        elseif vim.g.os == "WSL" then
            system = "linux"
        elseif vim.g.os == "Darwin" then
            system = "mac"
        end
        local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")

        -- DAP: both of java-debug-adapter and java-test are ought to be installed. (https://github.com/mfussenegger/nvim-jdtls#debugger-via-nvim-dap)
        local debug_adapter_dir = registry.get_package("java-debug-adapter"):get_install_path()
        local java_test_dir = registry.get_package("java-test"):get_install_path()

        local bundles = { vim.fn.glob(debug_adapter_dir .. "/extension/server/com.microsoft.java.debug.plugin-*.jar") }
        vim.list_extend(bundles, vim.split(vim.fn.glob(java_test_dir .. "/extension/server/*.jar"), "\n"))

        jdtls.start_or_attach({
            -- masonが入れた付属の`jdtls`(pythonスクリプト)はfull-featureには使えない?
            cmd = {
                "java",
                "-Declipse.application=org.eclipse.jdt.ls.core.id1",
                "-Dosgi.bundles.defaultStartLevel=4",
                "-Declipse.product=org.eclipse.jdt.ls.core.product",
                "-Dlog.protocol=true",
                "-Dlog.level=ALL",
                "-Xms1g",
                "--add-modules=ALL-SYSTEM",
                "--add-opens",
                "java.base/java.util=ALL-UNNAMED",
                "-jar",
                jar_path,
                "-configuration",
                pkg_dir .. "/config_" .. system,
                -- See `data directory configuration` section in the README
                "-data",
                vim.env.HOME .. "/Documents/eclipse-workspace/jdt.ls/" .. project_name,
            },
            init_options = { bundles = bundles },
        })
        ]]
    end,
})
