--- vim-fern と LSP の workspace file operation を統合するモジュール
--- fern の ftplugin から M.setup_keymaps() を呼び出して使う

local M = {}

--- workspace file operation の capability を持つ LSP クライアントを返す
---@param capability string "willRename"|"didRename"|"willCreate"|"didCreate"|"willDelete"|"didDelete"
---@return vim.lsp.Client[]
local function get_capable_clients(capability)
    return vim.tbl_filter(function(client)
        local ops = vim.tbl_get(client.server_capabilities, "workspace", "fileOperations")
        return ops ~= nil and ops[capability] ~= nil
    end, vim.lsp.get_clients())
end

--- workspace edit をバッファに適用する
---@param edit lsp.WorkspaceEdit
---@param offset_encoding string
local function apply_workspace_edit(edit, offset_encoding)
    vim.lsp.util.apply_workspace_edit(edit, offset_encoding or "utf-8")
end

--- workspace/willRenameFiles を送信し、返された workspace edit を適用する
---@param old_path string 変更前のファイルパス (絶対パス)
---@param new_path string 変更後のファイルパス (絶対パス)
function M.will_rename_files(old_path, new_path)
    local params = {
        files = { { oldUri = vim.uri_from_fname(old_path), newUri = vim.uri_from_fname(new_path) } },
    }
    for _, client in ipairs(get_capable_clients("willRename")) do
        local result = client:request_sync("workspace/willRenameFiles", params, 1500)
        if result and not result.err and result.result then
            apply_workspace_edit(result.result, client.offset_encoding)
        end
    end
end

--- workspace/didRenameFiles を送信する
---@param old_path string 変更前のファイルパス (絶対パス)
---@param new_path string 変更後のファイルパス (絶対パス)
function M.did_rename_files(old_path, new_path)
    local params = {
        files = { { oldUri = vim.uri_from_fname(old_path), newUri = vim.uri_from_fname(new_path) } },
    }
    for _, client in ipairs(get_capable_clients("didRename")) do
        client:notify("workspace/didRenameFiles", params)
    end
end

--- workspace/willCreateFiles を送信し、返された workspace edit を適用する
---@param paths string[] 作成するファイルのパスのリスト (絶対パス)
function M.will_create_files(paths)
    local params = {
        files = vim.tbl_map(function(p)
            return { uri = vim.uri_from_fname(p) }
        end, paths),
    }
    for _, client in ipairs(get_capable_clients("willCreate")) do
        local result = client:request_sync("workspace/willCreateFiles", params, 1500)
        if result and not result.err and result.result then
            apply_workspace_edit(result.result, client.offset_encoding)
        end
    end
end

--- workspace/didCreateFiles を送信する
---@param paths string[] 作成されたファイルのパスのリスト (絶対パス)
function M.did_create_files(paths)
    local params = {
        files = vim.tbl_map(function(p)
            return { uri = vim.uri_from_fname(p) }
        end, paths),
    }
    for _, client in ipairs(get_capable_clients("didCreate")) do
        client:notify("workspace/didCreateFiles", params)
    end
end

--- workspace/willDeleteFiles を送信し、返された workspace edit を適用する
---@param paths string[] 削除するファイルのパスのリスト (絶対パス)
function M.will_delete_files(paths)
    local params = {
        files = vim.tbl_map(function(p)
            return { uri = vim.uri_from_fname(p) }
        end, paths),
    }
    for _, client in ipairs(get_capable_clients("willDelete")) do
        local result = client:request_sync("workspace/willDeleteFiles", params, 1500)
        if result and not result.err and result.result then
            apply_workspace_edit(result.result, client.offset_encoding)
        end
    end
end

--- workspace/didDeleteFiles を送信する
---@param paths string[] 削除されたファイルのパスのリスト (絶対パス)
function M.did_delete_files(paths)
    local params = {
        files = vim.tbl_map(function(p)
            return { uri = vim.uri_from_fname(p) }
        end, paths),
    }
    for _, client in ipairs(get_capable_clients("didDelete")) do
        client:notify("workspace/didDeleteFiles", params)
    end
end

--- fern の cursor node の絶対パスを返す
---@return string|nil
local function fern_cursor_path()
    local ok, path = pcall(vim.api.nvim_eval, "fern#helper#new().sync.get_cursor_node()._path")
    return (ok and type(path) == "string" and #path > 0) and path or nil
end

--- fern で選択 (またはマーク) されているノードの絶対パスのリストを返す
--- マークされたノードがなければ cursor node のパスを返す
---@return string[]|nil
local function fern_selected_paths()
    local ok, paths = pcall(
        vim.api.nvim_eval,
        "map(fern#helper#new().sync.get_selected_nodes(), {_, n -> n._path})"
    )
    return (ok and type(paths) == "table" and #paths > 0) and paths or nil
end

--- fern のツリーを再読み込みする
local function fern_reload()
    pcall(vim.fn["fern#action#call"], "reload:all")
end

--- vim-fern バッファ用の LSP file operation キーマップを設定する
--- fern の ftplugin から呼び出すこと
function M.setup_keymaps()
    -- ファイル/ディレクトリのリネーム (r)
    -- workspace/willRenameFiles でインポートパス等を事前更新し、
    -- リネーム後に workspace/didRenameFiles で LSP 内部状態を同期する
    vim.keymap.set("n", "r", function()
        local old_path = fern_cursor_path()
        if not old_path then
            return
        end

        local old_name = vim.fn.fnamemodify(old_path, ":t")
        vim.cmd("redraw")
        local new_name = vim.fn.input("New name: ", old_name)
        if new_name == "" or new_name == old_name then
            return
        end

        local new_path = vim.fn.fnamemodify(old_path, ":h") .. "/" .. new_name

        -- リネーム前に LSP へ通知して workspace edit (インポートパス変更等) を適用する
        M.will_rename_files(old_path, new_path)

        -- 実際にリネームする
        if vim.fn.rename(old_path, new_path) ~= 0 then
            vim.notify("[fern-lsp] Rename failed: " .. old_path, vim.log.levels.ERROR)
            return
        end

        -- 対応するバッファが開いていればパスを更新する
        for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_loaded(bufnr) and vim.api.nvim_buf_get_name(bufnr) == old_path then
                vim.api.nvim_buf_set_name(bufnr, new_path)
                vim.api.nvim_buf_call(bufnr, function()
                    vim.cmd("edit")
                end)
            end
        end

        -- リネーム後に LSP へ通知する
        M.did_rename_files(old_path, new_path)

        fern_reload()
    end, { buffer = true, desc = "Fern: rename with LSP notification" })

    -- 新規ファイル作成 (n)
    vim.keymap.set("n", "n", function()
        local cursor_path = fern_cursor_path()
        if not cursor_path then
            return
        end

        local dir = vim.fn.isdirectory(cursor_path) == 1 and cursor_path
            or vim.fn.fnamemodify(cursor_path, ":h")

        vim.cmd("redraw")
        local name = vim.fn.input("New file: ")
        if name == "" then
            return
        end

        local new_path = dir .. "/" .. name

        M.will_create_files({ new_path })

        if vim.fn.writefile({}, new_path) ~= 0 then
            vim.notify("[fern-lsp] Failed to create file: " .. new_path, vim.log.levels.ERROR)
            return
        end

        M.did_create_files({ new_path })
        fern_reload()
    end, { buffer = true, desc = "Fern: new file with LSP notification" })

    -- 新規ディレクトリ作成 (N)
    vim.keymap.set("n", "N", function()
        local cursor_path = fern_cursor_path()
        if not cursor_path then
            return
        end

        local dir = vim.fn.isdirectory(cursor_path) == 1 and cursor_path
            or vim.fn.fnamemodify(cursor_path, ":h")

        vim.cmd("redraw")
        local name = vim.fn.input("New dir: ")
        if name == "" then
            return
        end

        local new_path = dir .. "/" .. name

        M.will_create_files({ new_path })

        if vim.fn.mkdir(new_path, "p") ~= 1 then
            vim.notify("[fern-lsp] Failed to create directory: " .. new_path, vim.log.levels.ERROR)
            return
        end

        M.did_create_files({ new_path })
        fern_reload()
    end, { buffer = true, desc = "Fern: new directory with LSP notification" })

    -- ファイル/ディレクトリの削除 (D)
    -- workspace/willDeleteFiles で参照箇所の変更等を事前適用し、
    -- 削除後に workspace/didDeleteFiles で LSP 内部状態を同期する
    vim.keymap.set("n", "D", function()
        local paths = fern_selected_paths()
        if not paths or #paths == 0 then
            return
        end

        local names = table.concat(
            vim.tbl_map(function(p)
                return vim.fn.fnamemodify(p, ":t")
            end, paths),
            ", "
        )
        vim.cmd("redraw")
        local confirm = vim.fn.input("Delete " .. names .. "? [y/N]: ")
        if confirm:lower() ~= "y" then
            return
        end

        -- 削除前に LSP へ通知して workspace edit を適用する
        M.will_delete_files(paths)

        -- ファイルを削除する
        local deleted = {}
        for _, path in ipairs(paths) do
            local flags = vim.fn.isdirectory(path) == 1 and "rf" or ""
            if vim.fn.delete(path, flags) == 0 then
                table.insert(deleted, path)
            else
                vim.notify("[fern-lsp] Failed to delete: " .. path, vim.log.levels.WARN)
            end
        end

        if #deleted > 0 then
            -- 削除後に LSP へ通知する
            M.did_delete_files(deleted)
        end

        fern_reload()
    end, { buffer = true, desc = "Fern: delete with LSP notification" })
end

return M
