-- lua_post_source {{{
local registry = require("mason-registry")
local mason_lspconfig = require("mason-lspconfig")
local lspconfig = require("lspconfig")
local utils = require("xecua.utils")
local List = require("plenary.collections.py_list")

require("mason").setup({
    registries = {
        "lua:xecua.mason-registry",
        "github:mason-org/mason-registry",
    },
})

mason_lspconfig.setup({
    ensure_installed = {
        "pyright",
        "rust_analyzer",
        "clangd",
        "ts_ls",
        "vimls",
        "html",
        "efm",
        "gopls",
        "kotlin_language_server",
        "intelephense",
        "jdtls",
        "jsonls",
        "texlab",
        "tsp_server",
        "vacuum",
        "stylelint_lsp",
        "eslint",
        "lua_ls",
        "sqls",
        -- "satysfi-ls",
        -- "termux-language-server",
        "lemminx",
        "yamlls",
        "taplo",
        "typos_lsp",
        -- note: non-lsp servers are not considered: https://github.com/williamboman/mason.nvim/discussions/143#discussioncomment-3225734
    },
})

lspconfig.denols.setup({
    root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc", "denops"),
}) -- should have manually installed for denops
lspconfig.sourcekit.setup({}) -- bundled with swift toolchain

mason_lspconfig.setup_handlers({
    function(server_name)
        local ignore_servers = List({ "jdtls", "rust_analyzer", "ts_ls" })
        if not ignore_servers:contains(server_name) then
            lspconfig[server_name].setup({})
        end
    end,
    eslint = function()
        lspconfig.eslint.setup({
            settings = {
                eslint = {
                    autoFixOnSave = true,
                },
            },
        })
    end,
    intelephense = function()
        lspconfig.intelephense.setup({
            init_options = {
                globalStoragePath = vim.env.HOME .. "/.local/share/intelephense",
                licenceKey = vim.env.HOME .. "/.local/share/intelephense/licence.txt",
            },
        })
    end,
    lua_ls = function()
        require("neodev").setup({})
        lspconfig.lua_ls.setup({
            settings = {
                Lua = {
                    runtime = { version = "LuaJIT" },
                    format = { enable = false },
                },
            },
        })
    end,
    texlab = function()
        local forward_search_config = {}
        local os_string = utils.get_os_string()
        if os_string == "Linux" then
            forward_search_config = {
                executable = "zathura",
                args = { "--synctex-forward", "%l:1:%f", "%p" },
            }
        elseif os_string == "Windows" then
            forward_search_config = {
                executable = "SumatraPDF.exe", -- PATHに入れちゃうのがいいかなあ
                args = { "-reuse-instance", "%p", "-forward-search", "%f", "%l" },
            }
        elseif os_string == "Darwin" then
            forward_search_config = {
                executable = "/Applications/Skim.app/Contents/SharedSupport/displayline",
                args = { "%l", "%p", "%f" },
            }
        end

        lspconfig.texlab.setup({
            settings = {
                -- currently not supported? (https://github.com/latex-lsp/texlab/issues/427)
                texlab = {
                    auxDirectory = "./out",
                    build = {
                        args = {},
                    },
                    forwardSearch = forward_search_config,
                },
            },
        })
    end,
    jsonls = function()
        lspconfig.jsonls.setup({
            init_options = {
                provideFormatter = false,
            },
        })
    end,
    efm = function()
        local languages = require("xecua.plugins.efmls")
        lspconfig.efm.setup({
            filetypes = vim.tbl_keys(languages),
            init_options = {
                documentFormatting = true,
                documentRangeFormatting = true,
            },
            settings = { languages = languages },
        })
    end,
})

vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = { "java" },
    callback = function()
        -- setting up jdtls (this does not work when called in setup_handlers)
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
    end,
})
-- }}}
