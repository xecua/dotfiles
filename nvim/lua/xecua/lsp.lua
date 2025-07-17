-- vim.lsp.config('*', {})

vim.lsp.enable({
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
})

local augroup = vim.api.nvim_create_augroup("Lsp", {})

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
