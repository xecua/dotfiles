-- vim.lsp.config('*', {})

vim.lsp.enable({
    "copilot",
    "denols",
    -- "intelephense",
    "jsonls",
    "jdtls",
    "lua_ls", -- clangでコンパイルすると動かないかも(gcc libunwindが必要なため)
    "oxfmt",
    "oxlint",
    "texlab",
    "typescript",
    "yamlls",
    "zeta",

    "astro",
    "clangd",
    "eslint",
    "fish_lsp",
    "gopls",
    "html",
    "markdown_oxide",
    "kotlin_language_server",
    "lemminx",
    "nil_ls",
    "phpantom_lsp",
    "ruff",
    "rumdl",
    "sourcekit",
    "sqls",
    "stylelint_lsp",
    "stylua",
    "tinymist",
    "tombi",
    "tsp_server",
    "ty",
    "vimls",
    -- "typos_lsp",
    "zls",
})

local augroup = vim.api.nvim_create_augroup("Lsp", {})
vim.g.format_disabled_servers = { "typescript", "lua_ls", "sqls", "yamlls", "tombi" }
-- ↑に入っているものはserver capabilities自体を無効にするので、差分だけ入れればOK

--- バッファに登録したもの(autocmd/keymap/command等)をまとめて後で消せるようにする
--- @param buffer integer
local function new_scope(buffer)
    --- @type (fun())[]
    local undo = {}
    local scope = {}

    --- @param event string|string[]
    --- @param opts vim.api.keyset.create_autocmd
    function scope.autocmd(event, opts)
        local id =
            vim.api.nvim_create_autocmd(event, vim.tbl_extend("force", { group = augroup, buffer = buffer }, opts))
        table.insert(undo, function()
            pcall(vim.api.nvim_del_autocmd, id)
        end)
    end

    --- @param mode string|string[]
    --- @param lhs string
    --- @param rhs string|function
    --- @param opts? vim.keymap.set.Opts
    function scope.map(mode, lhs, rhs, opts)
        vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("force", { silent = true }, opts or {}, { buffer = buffer }))
        table.insert(undo, function()
            pcall(vim.keymap.del, mode, lhs, { buffer = buffer })
        end)
    end

    --- @param name string
    --- @param command string|function
    --- @param opts? vim.api.keyset.user_command
    function scope.command(name, command, opts)
        vim.api.nvim_buf_create_user_command(buffer, name, command, opts or {})
        table.insert(undo, function()
            pcall(vim.api.nvim_buf_del_user_command, buffer, name)
        end)
    end

    --- @param fn fun()
    function scope.on_teardown(fn)
        table.insert(undo, function()
            pcall(fn)
        end)
    end

    local function teardown()
        for i = #undo, 1, -1 do
            undo[i]()
        end
    end

    return scope, teardown
end

--- @alias xecua.lsp.FeatureSetup fun(scope: table, client: vim.lsp.Client, buffer: integer)

--- @class xecua.lsp.Feature
--- @field owners table<integer, true> この機能をサポートしているclientのid
--- @field bound_client integer setupに渡したclientのid
--- @field setup xecua.lsp.FeatureSetup
--- @field teardown fun()

--- features[buffer][name]
--- @type table<integer, table<string, xecua.lsp.Feature>>
local features = {}

--- bufferにおけるclientがこの機能をサポートしていることを登録する。最初の1つのときだけsetupが走る
--- @param name string
--- @param client vim.lsp.Client
--- @param buffer integer
--- @param setup xecua.lsp.FeatureSetup
local function acquire(name, client, buffer, setup)
    features[buffer] = features[buffer] or {}
    local feature = features[buffer][name]
    if not feature then
        local scope, teardown = new_scope(buffer)
        setup(scope, client, buffer)
        feature = {
            owners = {},
            bound_client = client.id,
            setup = setup,
            teardown = teardown,
        }
        features[buffer][name] = feature
    end
    feature.owners[client.id] = true
end

--- clientがbufferから外れたときに呼ぶ。サポートするclientがいなくなった機能は無効化し、
--- setupに渡したclientが外れた場合は残っているclientでsetupし直す
--- @param client_id integer
--- @param buffer integer
local function release(client_id, buffer)
    local buf_features = features[buffer]
    if not buf_features then
        return
    end
    for name, feature in pairs(buf_features) do
        if feature.owners[client_id] then
            feature.owners[client_id] = nil
            if feature.bound_client == client_id then
                feature.teardown()
                -- 残っているclientで作り直す
                local rebound = false
                for id, _ in pairs(feature.owners) do
                    local client = vim.lsp.get_client_by_id(id)
                    if client then
                        local scope, teardown = new_scope(buffer)
                        feature.setup(scope, client, buffer)
                        feature.teardown = teardown
                        feature.bound_client = id
                        rebound = true
                        break
                    end
                    feature.owners[id] = nil
                end
                if not rebound then
                    buf_features[name] = nil
                end
            elseif next(feature.owners) == nil then
                feature.teardown()
                buf_features[name] = nil
            end
        end
    end
    if next(buf_features) == nil then
        features[buffer] = nil
    end
end

--- @param name "inlay_hint"|"codelens"|"inline_completion"
--- @return xecua.lsp.FeatureSetup
local function capability_feature(name)
    return function(scope, _, buffer)
        -- buffer単位で有効にすれば、clientごとのattach/detachやdynamic registrationはNeovim側がやってくれる
        vim.lsp[name].enable(true, { bufnr = buffer })
        scope.on_teardown(function()
            if vim.api.nvim_buf_is_valid(buffer) then
                vim.lsp[name].enable(false, { bufnr = buffer })
            end
        end)
    end
end

--- メソッドに依らない機能
--- @type table<string, xecua.lsp.FeatureSetup>
local setups = {}

setups.general = function(scope, client)
    scope.command(
        "LspFormat",
        "lua vim.lsp.buf.format({ async = true })",
        { range = client:supports_method("textDocument/rangeFormatting") }
    )
    scope.command(
        "LspSignatureHelp",
        "lua vim.lsp.buf.signature_help({ border = 'single', focusable = false, focus = false, silent = true })"
    )
    scope.command("LspHover", "lua vim.lsp.buf.hover({ border = 'single' })")
    scope.command("LspReferences", "lua vim.lsp.buf.references()")
    scope.command("LspDefinition", "lua vim.lsp.buf.definition()")
    scope.command("LspTypeDefinition", "lua vim.lsp.buf.type_definition()")
    scope.command("LspSubtypes", "lua vim.lsp.buf.typehierarchy('subtypes')")
    scope.command("LspSupertypes", "lua vim.lsp.buf.typehierarchy('supertypes')")
    scope.command("LspImplementation", "lua vim.lsp.buf.implementation()")
    scope.command("LspCodeAction", "lua vim.lsp.buf.code_action()", { range = true })
    scope.command("LspDocumentSymbol", "lua vim.lsp.buf.document_symbol()")
    scope.command("LspWorkspaceSymbol", "lua vim.lsp.buf.workspace_symbol()")
    scope.command("LspIncomingCalls", "lua vim.lsp.buf.incoming_calls()")
    scope.command("LspOutgoingCalls", "lua vim.lsp.buf.outgoing_calls()")
    scope.command("LspCodeLensRun", "lua vim.lsp.codelens.run()")
    scope.command("LspRename", "lua vim.lsp.buf.rename()")

    scope.map("n", "K", "<Cmd>LspHover<CR>")
    scope.map("n", "<Leader>lh", "<Cmd>LspSignatureHelp<CR>")
    scope.map("n", "<Leader>lr", "<Cmd>LspReferences<CR>")
    scope.map("n", "<Leader>ld", "<Cmd>LspDefinition<CR>")
    scope.map("n", "<Leader>lt", "<Cmd>LspTypeDefinition<CR>")
    scope.map("n", "<Leader>lsd", "<Cmd>LspDocumentSymbol<CR>")
    scope.map("n", "<Leader>lsw", "<Cmd>LspWorkspaceSymbol<CR>")
    scope.map("n", "<Leader>lsb", "<Cmd>LspSubtypes<CR>")
    scope.map("n", "<Leader>lsp", "<Cmd>LspSupertypes<CR>")
    scope.map("n", "<Leader>li", "<Cmd>LspImplementation<CR>")
    scope.map({ "n", "v" }, "<Leader>la", "<Cmd>LspCodeAction<CR>")
    scope.map("n", "<Leader>l,", "<Cmd>LspIncomingCalls<CR>") -- ,+shift = < のきもち
    scope.map("n", "<Leader>l.", "<Cmd>LspOutgoingCalls<CR>") --.+shift = >
    scope.map("n", "<Leader>lc", "<Cmd>LspCodeLensRun<CR>")
    scope.map("n", "<Leader>ll", function()
        -- inlay hint/codelensはbuffer単位で有効にしているので、トグルもbuffer単位
        local filter = { bufnr = 0 }
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled(filter), filter)
        vim.lsp.codelens.enable(not vim.lsp.codelens.is_enabled(filter), filter)
    end)
    scope.map("n", "<F2>", "<Cmd>LspRename<CR>")
end

setups.nes = function(scope, client, buffer)
    local nes = require("copilot-lsp.nes")
    local debounced_request = require("copilot-lsp.util").debounce(nes.request_nes, 500)

    scope.autocmd("TextChanged", {
        callback = function()
            debounced_request(client)
        end,
    })
    scope.autocmd("BufEnter", {
        callback = function()
            local td_params = vim.lsp.util.make_text_document_params(buffer)
            ---@diagnostic disable-next-line: param-type-mismatch
            client:notify("textDocument/didFocus", { textDocument = { uri = td_params.uri } })
        end,
    })
    scope.autocmd("ModeChanged", {
        pattern = "i:n",
        callback = function()
            debounced_request(client)
        end,
    })

    scope.map("n", "<C-l>", function()
        nes.walk_cursor_start_edit()
        local changed = nes.apply_pending_nes()
        nes.walk_cursor_end_edit()

        if not changed then
            debounced_request(client)
        end
    end, { desc = "Copilot NES" })
    scope.map("n", "<C-c>", function()
        nes.clear()
    end, { desc = "Clear NES" })

    scope.on_teardown(function()
        if vim.api.nvim_buf_is_valid(buffer) then
            nes.clear_suggestion(buffer)
        end
    end)
end

setups.jdtls = function(scope)
    scope.command("LspOrganizeImports", 'lua require("jdtls").organize_imports()')
    scope.map("n", "<Leader>lo", "<Cmd>LspOrganizeImports<CR>")

    scope.command("LspTestClass", 'lua require("jdtls").test_class()')
    scope.map("n", "<Leader>dc", "<Cmd>LspTestClass<CR>")

    scope.command("LspTestMethod", 'lua require("jdtls").test_nearest_method()')
    scope.map("n", "<Leader>dm", "<Cmd>LspTestMethod<CR>")
end

--- メソッドごとの機能
--- @type table<vim.lsp.protocol.Method.ClientToServer, xecua.lsp.FeatureSetup>
local method_setups = {}

vim.g.format_disabled_servers_onsave = vim.g.format_disabled_servers_onsave or {}
method_setups["textDocument/formatting"] = function(scope)
    scope.autocmd("BufWritePre", {
        callback = function()
            vim.lsp.buf.format({
                filter = function(c)
                    return not vim.list_contains(vim.g.format_disabled_servers_onsave, c.name)
                end,
            })
        end,
    })
end

method_setups["textDocument/signatureHelp"] = function(scope)
    scope.autocmd("CursorHoldI", { command = "LspSignatureHelp" })
end

method_setups["textDocument/documentSymbol"] = function(scope, client, buffer)
    require("nvim-navic").attach(client, buffer)
    scope.on_teardown(function()
        vim.api.nvim_clear_autocmds({
            group = vim.api.nvim_create_augroup("navic", { clear = false }),
            buffer = buffer,
        })
        require("nvim-navic.lib").clear_buffer_data(buffer)
        if vim.api.nvim_buf_is_valid(buffer) then
            vim.b[buffer].navic_client_id = nil
            vim.b[buffer].navic_client_name = nil
        end
    end)
end

method_setups["textDocument/inlayHint"] = capability_feature("inlay_hint")
method_setups["textDocument/codeLens"] = capability_feature("codelens")
method_setups["textDocument/inlineCompletion"] = function(scope, client, buffer)
    capability_feature("inline_completion")(scope, client, buffer)
    scope.map("i", "<C-l>", function()
        return vim.lsp.inline_completion.get() and "" or "<C-l>"
    end, { expr = true })
end

--- @param client vim.lsp.Client
--- @param buffer integer
local on_capability_updated = function(client, buffer)
    -- 無効化する (configのcapabilitiesだとうまいこといかんっぽい)
    if vim.list_contains(vim.g.format_disabled_servers, client.name) then
        client.server_capabilities.documentFormattingProvider = nil
        client.server_capabilities.documentRangeFormattingProvider = nil
    end
    if client.name == "tombi" then
        -- そもそもそんなに複雑じゃないし injection効かせたいし
        client.server_capabilities.semanticTokensProvider = nil
    elseif client.name == "efm" then
        client.server_capabilities.documentSymbolProvider = nil
        client.server_capabilities.completionProvider = nil
        client.server_capabilities.codeActionProvider = nil
        client.server_capabilities.hoverProvider = nil
    end

    for method, setup in pairs(method_setups) do
        if client:supports_method(method) then
            acquire(method, client, buffer, setup)
        end
    end
end

vim.api.nvim_create_autocmd("LspAttach", {
    group = augroup,
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        local buffer = args.buf

        assert(client ~= nil)

        if client.name == "copilot" then
            if
                vim.g.disable_copilot
                or vim.bo[buffer].readonly
                or vim.list_contains({
                    "markdown",
                    "asciidoc",
                    "rst",
                    "textile",
                    "satysfi",
                    "typst",
                    "dap-repl",
                    "dap-view",
                    "dap-view-term",
                    "dap-view-help",
                }, vim.bo[buffer].filetype)
            then
                vim.lsp.buf_detach_client(buffer, client.id)
                return
            end

            if pcall(require, "copilot-lsp.nes") then
                acquire("nes", client, buffer, setups.nes)
            end
        elseif client.name == "jdtls" then
            acquire("jdtls", client, buffer, setups.jdtls)
        end

        acquire("general", client, buffer, setups.general)

        on_capability_updated(client, buffer)
    end,
})

vim.api.nvim_create_autocmd("LspDetach", {
    group = augroup,
    callback = function(args)
        release(args.data.client_id, args.buf)
    end,
})

-- バッファが先に消えた場合はLspDetachが来ないことがある。バッファローカルなものはバッファと一緒に消える
vim.api.nvim_create_autocmd("BufWipeout", {
    group = augroup,
    callback = function(args)
        features[args.buf] = nil
    end,
})

-- dynamic registrationに対応 (:h LspAttach)
vim.lsp.handlers["client/registerCapability"] = (function(overridden)
    return function(err, res, ctx)
        local result = overridden(err, res, ctx)
        local client = vim.lsp.get_client_by_id(ctx.client_id)
        if not client then
            return
        end
        for buffer, _ in pairs(client.attached_buffers) do
            on_capability_updated(client, buffer)
        end
        return result
    end
end)(vim.lsp.handlers["client/registerCapability"])

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
