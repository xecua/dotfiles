-- vim.lsp.config('*', {})

vim.lsp.enable({
    -- "denols",
    -- "eslint",
    "intelephense",
    "lua_ls",
    "texlab",
    "jsonls",
    "efm",

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
        local registry = require("mason-registry")

        -- TODO: nixで入れてるときにうまいこと取る方法を探る。それまでmasonで
        -- DAP: both of java-debug-adapter and java-test are ought to be installed. (https://github.com/mfussenegger/nvim-jdtls#debugger-via-nvim-dap)
        local debug_adapter_dir = registry.get_package("java-debug-adapter"):get_install_path()
        local java_test_dir = registry.get_package("java-test"):get_install_path()

        local bundles = { vim.fn.glob(debug_adapter_dir .. "/extension/server/com.microsoft.java.debug.plugin-*.jar") }
        vim.list_extend(bundles, vim.split(vim.fn.glob(java_test_dir .. "/extension/server/*.jar"), "\n"))

        require("jdtls").start_or_attach({ cmd = "jdtls", init_options = { bundles = bundles } })
    end,
})
