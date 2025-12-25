-- vim.lsp.config('*', {})

local methods = vim.lsp.protocol.Methods

vim.lsp.enable({
    "efm",
    "intelephense",
    "jsonls",
    "lua_ls", -- LLVM basedなシステムでは動かないかも(gcc libunwindが必要なため)
    "oxfmt",
    "oxlint",
    "taplo",
    "texlab",
    "tsgo",
    "yamlls",

    "astro",
    "clangd",
    "denols",
    "eslint",
    "fish_lsp",
    "gopls",
    "html",
    "kotlin_language_server",
    "lemminx",
    "nil_ls",
    "pyright",
    "rumdl",
    "sourcekit",
    "sqls",
    "stylelint_lsp",
    "tsp_server",
    "vimls",
    -- "typos_lsp",
})

if vim.g.use_copilot then
    vim.lsp.enable("copilot")
end

local augroup = vim.api.nvim_create_augroup("Lsp", {})

vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = { "java" },
    group = augroup,
    callback = function()
        local registry = require("mason-registry")

        -- DAP: both of java-debug-adapter and java-test are ought to be installed. (https://github.com/mfussenegger/nvim-jdtls#debugger-via-nvim-dap)
        local debug_adapter_dir = registry.get_package("java-debug-adapter"):get_install_path()
        local java_test_dir = registry.get_package("java-test"):get_install_path()

        local bundles = { vim.fn.glob(debug_adapter_dir .. "/extension/server/com.microsoft.java.debug.plugin-*.jar") }
        vim.list_extend(bundles, vim.split(vim.fn.glob(java_test_dir .. "/extension/server/*.jar"), "\n"))

        require("jdtls").start_or_attach({ cmd = "jdtls", init_options = { bundles = bundles } })
    end,
})

local format_autocmd_defined = {}
vim.api.nvim_create_autocmd("LspAttach", {
    group = augroup,
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        local buffer = args.buf

        vim.api.nvim_buf_create_user_command(buffer, "LspFormat", function()
            vim.lsp.buf.format({
                filter = function(c)
                    return not vim.tbl_contains({ "tsgo", "lua_ls", "sqls", "yamlls" }, c.name)
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
        vim.api.nvim_buf_create_user_command(buffer, "LspCodeAction", "lua vim.lsp.buf.code_action()", { range = true })
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
        vim.keymap.set({ "n", "v" }, "<Leader>la", "<Cmd>LspCodeAction<CR>", opts)
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

        if client:supports_method(methods.textDocument_documentSymbol) then
            require("nvim-navic").attach(client, buffer)
        end

        if client:supports_method(methods.textDocument_formatting) and format_autocmd_defined[buffer] then
            format_autocmd_defined[buffer] = true
            vim.api.nvim_create_autocmd("BufWritePre", {
                group = augroup,
                buffer = buffer,
                command = "LspFormat",
                desc = "LSP: Format on save",
            })
        end

        if client:supports_method(methods.textDocument_inlayHint) then
            vim.lsp.inlay_hint.enable()
        end

        if
            vim.fn.has("nvim-0.12") == 1
            and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlineCompletion)
        then
            vim.lsp.inline_completion.enable()
            vim.keymap.set({ "i", "n" }, "<C-l>", function()
                if require("sidekick").nes_jump_or_apply() then
                    return
                end
                if vim.lsp.inline_completion.get() then
                    return
                end
                return "<C-l>"
            end, { silent = true, expr = true, buffer = buffer })
        end

        if client:supports_method(methods.textDocument_signatureHelp) then
            vim.api.nvim_create_autocmd("CursorHoldI", {
                group = augroup,
                buffer = buffer,
                command = "LspSignatureHelp",
                desc = "LSP: Signature Help while Typing.",
            })
        end
    end,
})

-- https://www.reddit.com/r/neovim/comments/1gf7kyn/lsp_configuration_debugging/
local function inspect_lsp_client()
    vim.ui.input({ prompt = "Enter LSP Client name: " }, function(client_name)
        if client_name then
            local client = vim.lsp.get_clients({ name = client_name })

            if #client == 0 then
                vim.notify("No active LSP clients found with this name: " .. client_name, vim.log.levels.WARN)
                return
            end

            -- Create a temporary buffer to show the configuration
            local buf = vim.api.nvim_create_buf(false, true)
            local win = vim.api.nvim_open_win(buf, true, {
                relative = "editor",
                width = math.floor(vim.o.columns * 0.75),
                height = math.floor(vim.o.lines * 0.90),
                col = math.floor(vim.o.columns * 0.125),
                row = math.floor(vim.o.lines * 0.05),
                style = "minimal",
                border = "rounded",
                title = " " .. (client_name:gsub("^%l", string.upper)) .. ": LSP Configuration ",
                title_pos = "center",
            })

            local lines = {}
            for i, this_client in ipairs(client) do
                if i > 1 then
                    table.insert(lines, string.rep("-", 80))
                end
                table.insert(lines, "Client: " .. this_client.name)
                table.insert(lines, "ID: " .. this_client.id)
                table.insert(lines, "")
                table.insert(lines, "Configuration:")

                local config_lines = vim.split(vim.inspect(this_client.config), "\n")
                vim.list_extend(lines, config_lines)
            end

            -- Set the lines in the buffer
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

            -- Set buffer options
            vim.bo[buf].modifiable = false
            vim.bo[buf].filetype = "lua"
            vim.bo[buf].bh = "delete"

            vim.api.nvim_buf_set_keymap(buf, "n", "q", ":q<CR>", { noremap = true, silent = true })
        end
    end)
end

vim.api.nvim_create_user_command("LspInspectClient", inspect_lsp_client, {})
vim.api.nvim_create_user_command("LspInfo", ":checkhealth vim.lsp", {})
vim.api.nvim_create_user_command("LspLog", function()
    vim.cmd(string.format("tabnew %s", vim.lsp.log.get_filename()))
end, {
    desc = "Opens the Nvim LSP client log.",
})
