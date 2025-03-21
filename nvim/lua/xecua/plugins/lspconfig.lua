-- lua_source {{{
local registry = require("mason-registry")
local lspconfig = require("lspconfig")

require("mason").setup({
    registries = {
        "lua:xecua.mason-registry",
        "github:mason-org/mason-registry",
    },
})

require("nlspsettings").setup({
    nvim_notify = { enable = true },
})

local servers = {
    "denols",
    "eslint",
    "intelephense",
    "lua_ls",
    "texlab",
    "jsonls",
    "efm",

    "sourcekit",
    "nil_ls",
    "astro",
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
}

-- NOTE: nvim-lspconfigが0.11仕様になったらvim.lsp.enableにしてlua/xecua/lspは消す
-- vim.lsp.config("*", {})
-- vim.lsp.enable(servers)

for _, server in ipairs(servers) do
    local ok, config = pcall(require, "xecua.lsp." .. server)
    if ok then
        lspconfig[server].setup(config)
    else
        lspconfig[server].setup({})
    end
end

-- _default.lua
vim.keymap.del("n", "grn")
vim.keymap.del({ "n", "x" }, "gra")
vim.keymap.del("n", "grr")
vim.keymap.del("n", "gri")
vim.keymap.del("n", "gO")

local augroup = vim.api.nvim_create_augroup("LspConfig", {})
vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = { "java" },
    group = augroup,
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

vim.api.nvim_create_autocmd("LspAttach", {
    group = augroup,
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        local buffer = args.buf
        vim.api.nvim_buf_create_user_command(buffer, "LspFormat", function()
            vim.lsp.buf.format({
                filter = function(c)
                    return c.name ~= "typescript-tools" and c.name ~= "lua_ls" and c.name ~= "sqls"
                end,
            })
        end, {})
        vim.api.nvim_buf_create_user_command(buffer, "LspHover", function()
            vim.lsp.buf.hover({
                border = "single",
                focusable = false,
                focus = false,
                silent = true,
            })
        end, {})
        vim.api.nvim_buf_create_user_command(buffer, "LspSignatureHelp", function()
            vim.lsp.buf.signature_help({
                border = "single",
                focusable = false,
                focus = false,
                silent = true,
            })
        end, {})
        vim.api.nvim_buf_create_user_command(buffer, "LspReferences", "lua vim.lsp.buf.references()", {})
        vim.api.nvim_buf_create_user_command(buffer, "LspDefinition", "lua vim.lsp.buf.definition()", {})
        vim.api.nvim_buf_create_user_command(buffer, "LspTypeDefinition", "lua vim.lsp.buf.type_definition()", {})
        vim.api.nvim_buf_create_user_command(buffer, "LspImplementation", "lua vim.lsp.buf.implementation()", {})
        vim.api.nvim_buf_create_user_command(buffer, "LspCodeAction", "lua vim.lsp.buf.code_action()", {})
        vim.api.nvim_buf_create_user_command(buffer, "LspIncomingCalls", "lua vim.lsp.buf.incoming_calls()", {})
        vim.api.nvim_buf_create_user_command(buffer, "LspOutgoingCalls", "lua vim.lsp.buf.outgoing_calls()", {})
        vim.api.nvim_buf_create_user_command(buffer, "LspRename", "lua vim.lsp.buf.rename()", {})

        -- Mappings.
        local opts = { buffer = buffer, silent = true }

        -- LSP related: preceded by <Leader>l
        vim.keymap.set("n", "K", "<Cmd>LspHover<CR>", opts)
        vim.keymap.set("n", "<Leader>lh", "<Cmd>LspSignatureHelp<CR>", opts)
        vim.keymap.set("n", "<Leader>lr", "<Cmd>LspReferences<CR>", opts)
        vim.keymap.set("n", "<Leader>ld", "<Cmd>LspDefinition<CR>", opts)
        vim.keymap.set("n", "<Leader>lt", "<Cmd>LspTypeDefinition<CR>", opts)
        vim.keymap.set("n", "<Leader>li", "<Cmd>LspImplementation<CR>", opts)
        vim.keymap.set("n", "<Leader>la", "<Cmd>LspCodeAction<CR>", opts)
        vim.keymap.set("n", "<Leader>lci", "<Cmd>LspIncomingCalls<CR>", opts)
        vim.keymap.set("n", "<Leader>lco", "<Cmd>LspOutgoingCalls<CR>", opts)
        vim.keymap.set("n", "<F2>", "<Cmd>LspRename<CR>", opts)
        vim.keymap.set({ "i", "s" }, "<C-s>", "<Cmd>LspSignatureHelp<CR>", opts)

        if client.name == "jdtls" then
            vim.api.nvim_buf_create_user_command(
                buffer,
                "LspOrganizeImports",
                'lua require("jdtls").organize_imports()',
                {}
            )
            vim.keymap.set("n", "<Leader>lo", "<Cmd>LspOrganizeImports<CR>", { buffer = buffer, silent = true })

            vim.api.nvim_buf_create_user_command(buffer, "LspTestClass", 'lua require("jdtls").test_class()', {})
            vim.keymap.set("n", "<Leader>dc", "<Cmd>LspTestClass<CR>", { buffer = buffer, silent = true })

            vim.api.nvim_buf_create_user_command(
                buffer,
                "LspTestMethod",
                'lua require("jdtls").test_nearest_method()',
                {}
            )
            vim.keymap.set("n", "<Leader>dm", "<Cmd>LspTestMethod<CR>", { buffer = buffer, silent = true })

            require("jdtls").setup_dap({ hotcodereplace = "auto" })
        end

        if client:supports_method("textDocument/documentSymbol") then
            require("nvim-navic").attach(client, buffer)
        end

        if client:supports_method("textDocument/formatting") then
            vim.api.nvim_create_autocmd("BufWritePre", {
                group = augroup,
                buffer = buffer,
                command = "LspFormat",
                desc = "LSP: Format on save",
            })
        end

        if client:supports_method("textDocument/inlayHint") then
            vim.lsp.inlay_hint.enable()
        end

        if client:supports_method("textDocument/signatureHelp") then
            vim.api.nvim_create_autocmd("CursorHoldI", {
                group = augroup,
                buffer = buffer,
                command = "LspSignatureHelp",
                desc = "LSP: Signature Help while Typing.",
            })
        end
    end,
})

-- }}}
