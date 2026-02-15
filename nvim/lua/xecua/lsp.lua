-- vim.lsp.config('*', {})

vim.lsp.enable({
    "denols",
    "efm",
    "intelephense",
    "jsonls",
    "lua_ls", -- clangでコンパイルすると動かないかも(gcc libunwindが必要なため)
    "oxfmt",
    "oxlint",
    "texlab",
    "tsgo",
    "yamlls",

    "astro",
    "clangd",
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
    -- "tombi", -- キーでソートする機能あるけどいらない…… oxfmtで
    "tsp_server",
    "vimls",
    -- "typos_lsp",
})

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

        assert(client ~= nil)
        if client.name == "GitHub Copilot" and vim.fn["copilot#Enabled"]() == 0 then
            -- VimEnterで起動するときはg:copilot_filetypesが無視される(PR案件な気もするけど)
            client:stop()
            return
        end

        local mapopts = { buffer = buffer, silent = true }

        if client:supports_method("textDocument/formatting") then
            vim.api.nvim_buf_create_user_command(buffer, "LspFormat", function()
                vim.lsp.buf.format({
                    filter = function(c)
                        return not vim.tbl_contains({ "tsgo", "lua_ls", "sqls", "yamlls", "tombi" }, c.name)
                    end,
                })
            end, { range = client:supports_method("textDocument/rangeFormatting") })
            if not format_autocmd_defined[buffer] then
                format_autocmd_defined[buffer] = true
                vim.api.nvim_create_autocmd("BufWritePre", { group = augroup, buffer = buffer, command = "LspFormat" })
            end
        end

        if client:supports_method("textDocument/hover") then
            vim.api.nvim_buf_create_user_command(buffer, "LspHover", function()
                vim.lsp.buf.hover({
                    border = "single",
                    focusable = false,
                    focus = false,
                    silent = true,
                })
            end, {})
            vim.keymap.set("n", "K", "<Cmd>LspHover<CR>", mapopts)
        end

        if client:supports_method("textDocument/signatureHelp") then
            vim.api.nvim_buf_create_user_command(buffer, "LspSignatureHelp", function()
                vim.lsp.buf.signature_help({ border = "single", focusable = false, focus = false, silent = true })
            end, {})
            vim.api.nvim_create_autocmd(
                "CursorHoldI",
                { group = augroup, buffer = buffer, command = "LspSignatureHelp" }
            )
            vim.keymap.set("n", "<Leader>lh", "<Cmd>LspSignatureHelp<CR>", mapopts)
            vim.keymap.set({ "i", "s" }, "<C-s>", "<Cmd>LspSignatureHelp<CR>", mapopts)
        end

        if client:supports_method("textDocument/references") then
            vim.api.nvim_buf_create_user_command(buffer, "LspReferences", "lua vim.lsp.buf.references()", {})
            vim.keymap.set("n", "<Leader>lr", "<Cmd>LspReferences<CR>", mapopts)
        end

        if client:supports_method("textDocument/definition") then
            vim.api.nvim_buf_create_user_command(buffer, "LspDefinition", "lua vim.lsp.buf.definition()", {})
            vim.keymap.set("n", "<Leader>ld", "<Cmd>LspDefinition<CR>", mapopts)
        end
        if client:supports_method("textDocument/typeDefinition") then
            vim.api.nvim_buf_create_user_command(buffer, "LspTypeDefinition", "lua vim.lsp.buf.type_definition()", {})
            vim.keymap.set("n", "<Leader>lt", "<Cmd>LspTypeDefinition<CR>", mapopts)
        end
        if client:supports_method("typeHierarchy/subtypes") then
            vim.api.nvim_buf_create_user_command(buffer, "LspSubtypes", "lua vim.lsp.buf.typehierarchy('subtypes')", {})
            vim.keymap.set("n", "<Leader>lsb", "<Cmd>LspSubtypes<CR>", mapopts)
        end
        if client:supports_method("typeHierarchy/supertypes") then
            vim.api.nvim_buf_create_user_command(
                buffer,
                "LspSupertypes",
                "lua vim.lsp.buf.typehierarchy('supertypes')",
                {}
            )
            vim.keymap.set("n", "<Leader>lsp", "<Cmd>LspSupertypes<CR>", mapopts)
        end
        if client:supports_method("textDocument/implementation") then
            vim.api.nvim_buf_create_user_command(buffer, "LspImplementation", "lua vim.lsp.buf.implementation()", {})
            vim.keymap.set("n", "<Leader>li", "<Cmd>LspImplementation<CR>", mapopts)
        end
        if client:supports_method("textDocument/codeAction") then
            vim.api.nvim_buf_create_user_command(
                buffer,
                "LspCodeAction",
                "lua vim.lsp.buf.code_action()",
                { range = true }
            )
            vim.keymap.set({ "n", "v" }, "<Leader>la", "<Cmd>LspCodeAction<CR>", mapopts)
        end
        if client:supports_method("callHierarchy/incomingCalls") then
            vim.api.nvim_buf_create_user_command(buffer, "LspIncomingCalls", "lua vim.lsp.buf.incoming_calls()", {})
            vim.keymap.set("n", "<Leader>lci", "<Cmd>LspIncomingCalls<CR>", mapopts)
        end
        if client:supports_method("callHierarchy/outgoingCalls") then
            vim.api.nvim_buf_create_user_command(buffer, "LspOutgoingCalls", "lua vim.lsp.buf.outgoing_calls()", {})
            vim.keymap.set("n", "<Leader>lco", "<Cmd>LspOutgoingCalls<CR>", mapopts)
        end
        if client:supports_method("textDocument/rename") then
            vim.api.nvim_buf_create_user_command(buffer, "LspRename", "lua vim.lsp.buf.rename()", {})
            vim.keymap.set("n", "<F2>", "<Cmd>LspRename<CR>", mapopts)
        end

        if client:supports_method("textDocument/documentSymbol") then
            require("nvim-navic").attach(client, buffer)
        end

        if client:supports_method("textDocument/inlayHint") then
            vim.lsp.inlay_hint.enable()
        end

        if client:supports_method("textDocument/codeLens") then
            vim.lsp.codelens.enable()
            vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
                group = augroup,
                buffer = buffer,
                command = "lua vim.lsp.codelens.enable()",
            })
        end

        if vim.fn.has("nvim-0.12") == 1 and client:supports_method("textDocument/inlineCompletion") then
            vim.lsp.inline_completion.enable()
            vim.keymap.set("i", "<C-l>", function()
                return vim.lsp.inline_completion.get() and "" or "<C-l>"
            end, { silent = true, expr = true, buffer = buffer })
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

            vim.api.nvim_buf_create_user_command(
                buffer,
                "LspTestMethod",
                'lua require("jdtls").test_nearest_method()',
                {}
            )
            vim.keymap.set("n", "<Leader>dm", "<Cmd>LspTestMethod<CR>", { buffer = buffer, silent = true })

            require("jdtls").setup_dap({ hotcodereplace = "auto" })
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
            vim.api.nvim_open_win(buf, true, {
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
