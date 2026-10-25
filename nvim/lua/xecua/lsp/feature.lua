-- バッファごとに、LSP clientが必要とする機能(autocmd/keymap/command等)を管理する。
-- 機能はそれを必要とするclientが最初に現れたときにsetupし、いなくなったら(LspDetach)片付ける。

local M = {}

local augroup = vim.api.nvim_create_augroup("xecua.lsp.feature", {})

--- @class xecua.lsp.Scope
--- @field autocmd fun(event: string|string[], opts: vim.api.keyset.create_autocmd)
--- @field map fun(mode: string|string[], lhs: string, rhs: string|function, opts?: vim.keymap.set.Opts)
--- @field command fun(name: string, command: string|function, opts?: vim.api.keyset.user_command)
--- @field on_teardown fun(fn: fun())

--- @alias xecua.lsp.FeatureSetup fun(scope: xecua.lsp.Scope, client: vim.lsp.Client, buffer: integer)

--- バッファに登録したものをまとめて後で消せるようにする
--- @param buffer integer
--- @return xecua.lsp.Scope scope
--- @return fun() teardown
local function new_scope(buffer)
    --- @type (fun())[]
    local undo = {}
    local scope = {}

    function scope.autocmd(event, opts)
        local id =
            vim.api.nvim_create_autocmd(event, vim.tbl_extend("force", { group = augroup, buffer = buffer }, opts))
        table.insert(undo, function()
            pcall(vim.api.nvim_del_autocmd, id)
        end)
    end

    function scope.map(mode, lhs, rhs, opts)
        vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("force", { silent = true }, opts or {}, { buffer = buffer }))
        table.insert(undo, function()
            pcall(vim.keymap.del, mode, lhs, { buffer = buffer })
        end)
    end

    function scope.command(name, command, opts)
        vim.api.nvim_buf_create_user_command(buffer, name, command, opts or {})
        table.insert(undo, function()
            pcall(vim.api.nvim_buf_del_user_command, buffer, name)
        end)
    end

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

--- @class xecua.lsp.Feature
--- @field owners table<integer, true> この機能を必要としているclientのid
--- @field bound_client integer setupに渡したclientのid
--- @field setup xecua.lsp.FeatureSetup
--- @field teardown fun()

--- features[buffer][name]
--- @type table<integer, table<string, xecua.lsp.Feature>>
local features = {}

--- @param feature xecua.lsp.Feature
--- @param client vim.lsp.Client
--- @param buffer integer
local function bind(feature, client, buffer)
    local scope, teardown = new_scope(buffer)
    feature.setup(scope, client, buffer)
    feature.teardown = teardown
    feature.bound_client = client.id
end

--- clientがbufferでこの機能を必要としていることを登録する。最初の1つのときだけsetupが走る
--- @param name string
--- @param client vim.lsp.Client
--- @param buffer integer
--- @param setup xecua.lsp.FeatureSetup
function M.acquire(name, client, buffer, setup)
    features[buffer] = features[buffer] or {}
    local feature = features[buffer][name]
    if not feature then
        feature = { owners = {}, bound_client = client.id, setup = setup, teardown = function() end }
        bind(feature, client, buffer)
        features[buffer][name] = feature
    end
    feature.owners[client.id] = true
end

--- 必要とするclientがいなくなった機能は片付け、setupに渡したclientが外れた機能は残っているclientでsetupし直す
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
            if feature.bound_client == client_id or next(feature.owners) == nil then
                feature.teardown()
                buf_features[name] = nil
                for id, _ in pairs(feature.owners) do
                    local client = vim.lsp.get_client_by_id(id)
                    if client then
                        bind(feature, client, buffer)
                        buf_features[name] = feature
                        break
                    end
                    feature.owners[id] = nil
                end
            end
        end
    end
    if next(buf_features) == nil then
        features[buffer] = nil
    end
end

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

return M
