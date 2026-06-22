-- workspace file operation capabilities を全 LSP サーバに宣言する
-- LSP サーバ側が willRenameFiles 等を登録するために必要
vim.lsp.config("*", {
    capabilities = vim.tbl_deep_extend("force", vim.lsp.protocol.make_client_capabilities(), {
        workspace = {
            fileOperations = {
                didCreate = true,
                willCreate = true,
                didRename = true,
                willRename = true,
                didDelete = true,
                willDelete = true,
            },
        },
    }),
})

vim.lsp.enable({
    "denols",
    -- "intelephense",
    "jsonls",
    "jdtls",
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
    "rumdl",
    "ruff",
    "sourcekit",
    "sqls",
    "stylelint_lsp",
    "stylua",
    "tombi",
    "tsp_server",
    "ty",
    "vimls",
    -- "typos_lsp",
    "zls",
})

local augroup = vim.api.nvim_create_augroup("Lsp", {})
vim.g.format_disabled_servers = { "tsgo", "lua_ls", "sqls", "yamlls", "tombi" }
-- ↑に入っているものはserver capabilities自体を無効にするので、差分だけ入れればOK
vim.g.format_disabled_servers_onsave = {}
local command_defined = { general = {}, nes = {}, format = {}, signature = {}, lens = {}, inline_completion = {} }
vim.api.nvim_create_autocmd("LspAttach", {
    group = augroup,
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        local buffer = args.buf

        assert(client ~= nil)

        -- 無効化する (configのcapabilitiesだとうまいこといかんっぽい)
        if vim.list_contains(vim.g.format_disabled_servers, client.name) then
            client.server_capabilities.documentFormattingProvider = nil
            client.server_capabilities.documentRangeFormattingProvider = nil
        end

        if client.name == "GitHub Copilot" then
            if vim.fn["copilot#Enabled"]() == 0 then
                -- VimEnterで起動するときはg:copilot_filetypesが無視される
                client:stop()
                return
            end

            vim.keymap.set("n", "<C-l>", function()
                local bufnr = vim.api.nvim_get_current_buf()
                local state = vim.b[bufnr].nes_state
                local nes = require("copilot-lsp.nes")
                if state and not nes.walk_cursor_start_edit() then
                    nes.apply_pending_nes()
                    nes.walk_cursor_end_edit()
                end
                nes.request_nes("GitHub Copilot")
            end, { buffer = true, desc = "Copilot NES" })
            vim.keymap.set("n", "<C-c>", function()
                require("copilot-lsp.nes").clear()
            end, { buffer = true, desc = "Clear NES" })

            local ok, nes = pcall(require, "copilot-lsp.nes")
            if ok and not command_defined.nes[buffer] then
                command_defined.nes[buffer] = true
                vim.api.nvim_create_autocmd("TextChanged", {
                    callback = function()
                        nes.request_nes(client)
                    end,
                })
                vim.api.nvim_create_autocmd("ModeChanged", {
                    pattern = "i:n",
                    callback = function()
                        nes.request_nes(client)
                    end,
                })
                vim.api.nvim_create_autocmd("BufEnter", {
                    callback = function()
                        local td_params = vim.lsp.util.make_text_document_params()
                        client:notify("textDocument/didFocus", { textDocument = { uri = td_params.uri } })
                    end,
                })
            end
        elseif client.name == "tombi" then
            -- そもそもそんなに複雑じゃないし injection効かせたいし
            client.server_capabilities.semanticTokensProvider = nil
        elseif client.name == "efm" then
            client.server_capabilities.documentSymbolProvider = nil
            client.server_capabilities.completionProvider = nil
            client.server_capabilities.codeActionProvider = nil
            client.server_capabilities.hoverProvider = nil
        elseif client.name == "jdtls" then
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
        end

        if not command_defined.general[buffer] then
            vim.api.nvim_buf_create_user_command(
                buffer,
                "LspFormat",
                "lua vim.lsp.buf.format({ async = true })",
                { range = client:supports_method("textDocument/rangeFormatting") }
            )
            vim.api.nvim_buf_create_user_command(
                buffer,
                "LspSignatureHelp",
                "lua vim.lsp.buf.signature_help({ border = 'single', focusable = false, focus = false, silent = true })",
                {}
            )
            vim.api.nvim_buf_create_user_command(buffer, "LspHover", "lua vim.lsp.buf.hover({ border = 'single' })", {})
            vim.api.nvim_buf_create_user_command(buffer, "LspReferences", "lua vim.lsp.buf.references()", {})
            vim.api.nvim_buf_create_user_command(buffer, "LspDefinition", "lua vim.lsp.buf.definition()", {})
            vim.api.nvim_buf_create_user_command(buffer, "LspTypeDefinition", "lua vim.lsp.buf.type_definition()", {})
            vim.api.nvim_buf_create_user_command(buffer, "LspSubtypes", "lua vim.lsp.buf.typehierarchy('subtypes')", {})
            vim.api.nvim_buf_create_user_command(
                buffer,
                "LspSupertypes",
                "lua vim.lsp.buf.typehierarchy('supertypes')",
                {}
            )
            vim.api.nvim_buf_create_user_command(buffer, "LspImplementation", "lua vim.lsp.buf.implementation()", {})
            vim.api.nvim_buf_create_user_command(
                buffer,
                "LspCodeAction",
                "lua vim.lsp.buf.code_action()",
                { range = true }
            )
            vim.api.nvim_buf_create_user_command(buffer, "LspIncomingCalls", "lua vim.lsp.buf.incoming_calls()", {})
            vim.api.nvim_buf_create_user_command(buffer, "LspOutgoingCalls", "lua vim.lsp.buf.outgoing_calls()", {})
            vim.api.nvim_buf_create_user_command(buffer, "LspRename", "lua vim.lsp.buf.rename()", {})

            local mapopts = { buffer = buffer, silent = true }
            vim.keymap.set("n", "K", "<Cmd>LspHover<CR>", mapopts)
            vim.keymap.set("n", "<Leader>lh", "<Cmd>LspSignatureHelp<CR>", mapopts)
            vim.keymap.set({ "i", "s" }, "<C-s>", "<Cmd>LspSignatureHelp<CR>", mapopts)
            vim.keymap.set("n", "<Leader>lr", "<Cmd>LspReferences<CR>", mapopts)
            vim.keymap.set("n", "<Leader>ld", "<Cmd>LspDefinition<CR>", mapopts)
            vim.keymap.set("n", "<Leader>lt", "<Cmd>LspTypeDefinition<CR>", mapopts)
            vim.keymap.set("n", "<Leader>lsb", "<Cmd>LspSubtypes<CR>", mapopts)
            vim.keymap.set("n", "<Leader>lsp", "<Cmd>LspSupertypes<CR>", mapopts)
            vim.keymap.set("n", "<Leader>li", "<Cmd>LspImplementation<CR>", mapopts)
            vim.keymap.set({ "n", "v" }, "<Leader>la", "<Cmd>LspCodeAction<CR>", mapopts)
            vim.keymap.set("n", "<Leader>lci", "<Cmd>LspIncomingCalls<CR>", mapopts)
            vim.keymap.set("n", "<Leader>lco", "<Cmd>LspOutgoingCalls<CR>", mapopts)
            vim.keymap.set("n", "<F2>", "<Cmd>LspRename<CR>", mapopts)
        end

        if client:supports_method("textDocument/formatting") and not command_defined.format[buffer] then
            command_defined.format[buffer] = true
            vim.api.nvim_create_autocmd("BufWritePre", {
                group = augroup,
                buffer = buffer,
                callback = function()
                    vim.lsp.buf.format({
                        filter = function(c)
                            return not vim.list_contains(vim.g.format_disabled_servers_onsave, c.name)
                        end,
                    })
                end,
            })
        end
        if client:supports_method("textDocument/signatureHelp") and not command_defined.signature[buffer] then
            command_defined.signature[buffer] = true
            vim.api.nvim_create_autocmd(
                "CursorHoldI",
                { group = augroup, buffer = buffer, command = "LspSignatureHelp" }
            )
        end

        if client:supports_method("textDocument/documentSymbol") then
            require("nvim-navic").attach(client, buffer)
        end

        if client:supports_method("textDocument/inlayHint") then
            vim.lsp.inlay_hint.enable()
        end

        if client:supports_method("textDocument/codeLens") then
            vim.lsp.codelens.enable()
            if not command_defined.lens[buffer] then
                command_defined.lens[buffer] = true
                vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
                    group = augroup,
                    buffer = buffer,
                    command = "lua vim.lsp.codelens.enable()",
                })
            end
        end

        if client:supports_method("textDocument/inlineCompletion") then
            vim.lsp.inline_completion.enable()
            if not command_defined.inline_completion[buffer] then
                command_defined.inline_completion[buffer] = true
                vim.keymap.set("i", "<C-l>", function()
                    return vim.lsp.inline_completion.get() and "" or "<C-l>"
                end, { silent = true, expr = true, buffer = buffer })
            end
        end
    end,
})

-- https://www.reddit.com/r/neovim/comments/1gf7kyn/lsp_configuration_debugging/
vim.api.nvim_create_user_command("LspInspectClient", function()
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
end, {})
vim.api.nvim_create_user_command("LspInfo", ":checkhealth vim.lsp", {})
vim.api.nvim_create_user_command("LspLog", function()
    vim.cmd(string.format("tabnew %s", vim.lsp.log.get_filename()))
end, {
    desc = "Opens the Nvim LSP client log.",
})
vim.api.nvim_create_user_command("LspCapabilities", function()
    vim.ui.input(
        { prompt = "Enter LSP Client name (leave empty for all clients attached to this buffer): " },
        function(client_name)
            if client_name == nil then
                return
            end
            local opt = { buffer = true }
            if client_name ~= "" then
                opt.name = client_name
            end
            local clients = vim.lsp.get_clients(opt)
            for _, client in ipairs(clients) do
                print(string.format("--- %s ---", client.name))
                print(vim.inspect(client.server_capabilities))
            end
        end
    )
end, {})
