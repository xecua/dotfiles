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

local feature = require("xecua.lsp.feature")

-- どのclientでも有効にする機能 ------------------------------------------------

--- @class xecua.lsp.Command
--- @field [1] string コマンド名
--- @field [2] fun() callback
--- @field [3] string 割り当てるキー
--- @field mode? string|string[] 有効にするモード
--- @field range? boolean

--- @type xecua.lsp.Command[]
local commands = {
    {
        "LspSignatureHelp",
        function()
            vim.lsp.buf.signature_help({ border = "single", focusable = false, focus = false, silent = true })
        end,
        "<Leader>lh",
    },
    {
        "LspHover",
        function()
            vim.lsp.buf.hover({ border = "single" })
        end,
        "K",
    },
    { "LspReferences", vim.lsp.buf.references, "<Leader>lr" },
    { "LspDefinition", vim.lsp.buf.definition, "<Leader>ld" },
    { "LspTypeDefinition", vim.lsp.buf.type_definition, "<Leader>lt" },
    { "LspDocumentSymbol", vim.lsp.buf.document_symbol, "<Leader>lsd" },
    { "LspWorkspaceSymbol", vim.lsp.buf.workspace_symbol, "<Leader>lsw" },
    {
        "LspSubtypes",
        function()
            vim.lsp.buf.typehierarchy("subtypes")
        end,
        "<Leader>lsb",
    },
    {
        "LspSupertypes",
        function()
            vim.lsp.buf.typehierarchy("supertypes")
        end,
        "<Leader>lsp",
    },
    { "LspImplementation", vim.lsp.buf.implementation, "<Leader>li" },
    { "LspCodeAction", vim.lsp.buf.code_action, "<Leader>la", mode = { "n", "v" }, range = true },
    { "LspIncomingCalls", vim.lsp.buf.incoming_calls, "<Leader>l," }, -- ,+shift = < のきもち
    { "LspOutgoingCalls", vim.lsp.buf.outgoing_calls, "<Leader>l." }, -- .+shift = >
    { "LspCodeLensRun", vim.lsp.codelens.run, "<Leader>lc" },
    { "LspRename", vim.lsp.buf.rename, "<F2>" },
}

--- 汎用コマンド/keymapの定義
--- @type xecua.lsp.FeatureSetup
local function define_commands(scope)
    scope.command("LspFormat", function(args)
        local range = args.range > 0
                and { start = { args.line1, 0 }, ["end"] = { args.line2, #vim.fn.getline(args.line2) } }
            or nil
        vim.lsp.buf.format({ async = true, range = range })
    end, { range = true })

    for _, c in ipairs(commands) do
        local name, callback, lhs = c[1], c[2], c[3]
        scope.command(name, function()
            callback()
        end, { range = c.range })
        scope.map(c.mode or "n", lhs, "<Cmd>" .. name .. "<CR>")
    end

    scope.map("n", "<Leader>ll", function()
        -- バッファの中で対応しているclientがいるものだけを対象に、どれか1つでも有効なら全部無効、全部無効なら全部有効にする。
        -- inlay hint/codelensはbuffer単位で有効にしているので、トグルもbuffer単位
        local filter = { bufnr = 0 }
        local has_inlay_hint = #vim.lsp.get_clients({ bufnr = 0, method = "textDocument/inlayHint" }) > 0
        local has_codelens = #vim.lsp.get_clients({ bufnr = 0, method = "textDocument/codeLens" }) > 0

        local enable = not (
            (has_inlay_hint and vim.lsp.inlay_hint.is_enabled(filter))
            or (has_codelens and vim.lsp.codelens.is_enabled(filter))
        )
        if has_inlay_hint then
            vim.lsp.inlay_hint.enable(enable, filter)
        end
        if has_codelens then
            vim.lsp.codelens.enable(enable, filter)
        end
    end)
end

-- clientが対応しているメソッドごとの機能 (キーのメソッド名をそのまま機能名として使う) --------

--- inlay hint等をbuffer単位で有効にする。clientごとのattach/detachやdynamic registrationはNeovim側がやってくれる
--- @param scope xecua.lsp.Scope
--- @param name "inlay_hint"|"codelens"|"inline_completion"
--- @param buffer integer
local function enable_capability(scope, name, buffer)
    vim.lsp[name].enable(true, { bufnr = buffer })
    scope.on_teardown(function()
        if vim.api.nvim_buf_is_valid(buffer) then
            vim.lsp[name].enable(false, { bufnr = buffer })
        end
    end)
end

-- 保存時のフォーマットに使わないサーバ。後ろのserversでフォーマット自体を無効にしたものは入れなくてよい
vim.g.format_disabled_servers_onsave = vim.g.format_disabled_servers_onsave or {}

--- @type table<vim.lsp.protocol.Method.ClientToServer, xecua.lsp.FeatureSetup>
local method_features = {
    ["textDocument/formatting"] = function(scope)
        scope.autocmd("BufWritePre", {
            callback = function()
                vim.lsp.buf.format({
                    filter = function(c)
                        return not vim.list_contains(vim.g.format_disabled_servers_onsave, c.name)
                    end,
                })
            end,
        })
    end,

    ["textDocument/signatureHelp"] = function(scope)
        scope.autocmd("CursorHoldI", { command = "LspSignatureHelp" })
    end,

    ["textDocument/documentSymbol"] = function(scope, client, buffer)
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
    end,

    ["textDocument/inlayHint"] = function(scope, _, buffer)
        enable_capability(scope, "inlay_hint", buffer)
    end,

    ["textDocument/codeLens"] = function(scope, _, buffer)
        enable_capability(scope, "codelens", buffer)
    end,

    ["textDocument/inlineCompletion"] = function(scope, _, buffer)
        enable_capability(scope, "inline_completion", buffer)
        scope.map("i", "<C-l>", function()
            return vim.lsp.inline_completion.get() and "" or "<C-l>"
        end, { expr = true })
    end,
}

-- サーバーごとの設定 ----------------------------------------------------------

local no_formatting = { "documentFormattingProvider", "documentRangeFormattingProvider" }

--- @class xecua.lsp.ServerSpec
--- @field should_attach? fun(buffer: integer): boolean falseを返したらそのバッファから外す
--- @field disabled_capabilities? string[] server_capabilitiesから消すもの (configのcapabilitiesだとうまいこといかんっぽい)
--- @field features? table<string, xecua.lsp.FeatureSetup>

--- @type table<string, xecua.lsp.ServerSpec>
local server_extra_config = {
    copilot = {
        should_attach = function(buffer)
            return not (
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
            )
        end,
        features = {
            nes = function(scope, client, buffer)
                local ok, nes = pcall(require, "copilot-lsp.nes")
                if not ok then
                    return
                end
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
                -- バッファローカルなautocmdにはpatternを指定できないので、モードはcallback内で見る
                scope.autocmd("ModeChanged", {
                    callback = function()
                        if vim.v.event.old_mode == "i" and vim.v.event.new_mode == "n" then
                            debounced_request(client)
                        end
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
            end,
        },
    },

    jdtls = {
        features = {
            jdtls = function(scope)
                scope.command("LspOrganizeImports", 'lua require("jdtls").organize_imports()')
                scope.map("n", "<Leader>lo", "<Cmd>LspOrganizeImports<CR>")

                scope.command("LspTestClass", 'lua require("jdtls").test_class()')
                scope.map("n", "<Leader>dc", "<Cmd>LspTestClass<CR>")

                scope.command("LspTestMethod", 'lua require("jdtls").test_nearest_method()')
                scope.map("n", "<Leader>dm", "<Cmd>LspTestMethod<CR>")
            end,
        },
    },

    typescript = { disabled_capabilities = no_formatting },
    lua_ls = { disabled_capabilities = no_formatting },
    sqls = { disabled_capabilities = no_formatting },
    yamlls = { disabled_capabilities = no_formatting },
    -- semantic tokens: そもそもそんなに複雑じゃないし injection効かせたいし
    tombi = { disabled_capabilities = vim.list_extend({ "semanticTokensProvider" }, no_formatting) },
    -- これしていてもリクエストへの応答はしてしまうのでクライアントでチェックする必要がある。ddu-source-lspはチェックなしでClient:request飛ばすのでダメ
    efm = {
        disabled_capabilities = {
            "documentSymbolProvider",
            "completionProvider",
            "codeActionProvider",
            "hoverProvider",
        },
    },
}

-- clientが付いたときの処理 ---------------------------------------------------

local augroup = vim.api.nvim_create_augroup("Lsp", {})

--- serversのdisabled_capabilitiesをclientのserver_capabilitiesから消す。何度呼んでもよい
--- @param client vim.lsp.Client
local function remove_disabled_capabilities(client)
    local spec = server_extra_config[client.name] or {}
    for _, capability in ipairs(spec.disabled_capabilities or {}) do
        client.server_capabilities[capability] = nil
    end
end

--- clientが必要とする機能(コマンド・メソッドごと・サーバーごと)をbufferで有効にする。何度呼んでもよい
--- @param client vim.lsp.Client
--- @param buffer integer
local function enable_features(client, buffer)
    local spec = server_extra_config[client.name] or {}

    feature.acquire("commands", client, buffer, define_commands)
    for method, setup in pairs(method_features) do
        if client:supports_method(method) then
            feature.acquire(method, client, buffer, setup)
        end
    end
    for name, setup in pairs(spec.features or {}) do
        feature.acquire(name, client, buffer, setup)
    end
end

vim.api.nvim_create_autocmd("LspAttach", {
    group = augroup,
    callback = function(args)
        local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
        local config = server_extra_config[client.name]
        if config and config.should_attach and not config.should_attach(args.buf) then
            -- LspAttachの時点ではまだattached_buffersに入ってないので遅延
            vim.schedule(function()
                if vim.lsp.buf_is_attached(args.buf, client.id) then
                    vim.lsp.buf_detach_client(args.buf, client.id)
                end
            end)
            return
        end
        remove_disabled_capabilities(client)
        enable_features(client, args.buf)
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
        remove_disabled_capabilities(client)
        for buffer, _ in pairs(client.attached_buffers) do
            enable_features(client, buffer)
        end
        return result
    end
end)(vim.lsp.handlers["client/registerCapability"])

-- デバッグ用 ------------------------------------------------------------------

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
