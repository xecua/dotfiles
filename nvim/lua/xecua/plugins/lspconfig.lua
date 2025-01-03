-- lua_post_source {{{
local M = {}

-- wrapper: https://zenn.dev/ryoppippi/articles/8aeedded34c914
local augroup = vim.api.nvim_create_augroup("LspConfig", {})
M.on_attach = function(callback)
    vim.api.nvim_create_autocmd("LspAttach", {
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

    -- commands
    vim.api.nvim_buf_create_user_command(buffer, "LspFormat", function()
        vim.lsp.buf.format({
            filter = function(c)
                return c.name ~= "typescript-tools" and c.name ~= "lua_ls" and c.name ~= "sqls"
            end,
        })
    end, {})
    vim.api.nvim_buf_create_user_command(buffer, "LspSignatureHelp", function()
        vim.lsp.buf.signature_help()
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
    vim.keymap.set("n", "<Leader>ls", "<Cmd>LspSignatureHelp<CR>", opts)
    vim.keymap.set("n", "<Leader>lr", "<Cmd>LspReferences<CR>", opts)
    vim.keymap.set("n", "<Leader>ld", "<Cmd>LspDefinition<CR>", opts)
    vim.keymap.set("n", "<Leader>lt", "<Cmd>LspTypeDefinition<CR>", opts)
    vim.keymap.set("n", "<Leader>li", "<Cmd>LspImplementation<CR>", opts)
    vim.keymap.set("n", "<Leader>la", "<Cmd>LspCodeAction<CR>", opts)
    vim.keymap.set("n", "<Leader>lci", "<Cmd>LspIncomingCalls<CR>", opts)
    vim.keymap.set("n", "<Leader>lco", "<Cmd>LspOutgoingCalls<CR>", opts)
    vim.keymap.set("n", "<F2>", "<Cmd>LspRename<CR>", opts)

    if client.name == "rust-analyzer" then
        vim.api.nvim_buf_create_user_command(buffer, "LspHoverActions", "RustLsp hover actions", {})
        vim.keymap.set("n", "<Leader>lh", "<Cmd>LspHoverActions<CR>", { buffer = buffer, silent = true })
    end
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

        vim.api.nvim_buf_create_user_command(buffer, "LspTestMethod", 'lua require("jdtls").test_nearest_method()', {})
        vim.keymap.set("n", "<Leader>dm", "<Cmd>LspTestMethod<CR>", { buffer = buffer, silent = true })

        require("jdtls").setup_dap({ hotcodereplace = "auto" })
    end

    if client.supports_method("textDocument/documentSymbol") then
        require("nvim-navic").attach(client, buffer)
    end

    if client.supports_method("textDocument/formatting") then
        vim.api.nvim_create_autocmd("BufWritePre", {
            group = augroup,
            buffer = buffer,
            command = "LspFormat",
            desc = "LSP: Format on save",
        })
    end

    if client.supports_method("textDocument/inlayHint") then
        vim.lsp.inlay_hint.enable()
    end
end)

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = "single",
    focusable = false,
    focus = false,
    silent = true,
})
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
    border = "single",
    focusable = false,
    focus = false,
    silent = true,
})

return M
-- }}}
