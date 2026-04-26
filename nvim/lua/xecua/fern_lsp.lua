--- vim-fern と LSP の workspace file operation を統合するモジュール
---
--- 使い方:
---   M.setup()         : VimEnter 等で一度だけ呼ぶ (fern-replacer BufWritePre/Post フック)
---   M.setup_keymaps() : fern の ftplugin から呼ぶ (バッファローカルキーマップ設定)

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

-- ----------------------------------------------------------------
-- 公開 API: 単一ファイル操作用
-- ----------------------------------------------------------------

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

-- ----------------------------------------------------------------
-- fern-replacer フック (rename)
-- ----------------------------------------------------------------

--- BufWritePre と BufWritePost/BufUnload の間でリネームペアを受け渡すテーブル
---@type table<integer, {old: string, new: string}[]>
local pending_renames = {}

--- fern-replacer バッファからリネームペアを計算して返す
--- b:fern_replacer_candidates (旧パスの配列) とバッファ各行 (新ファイル名) を突き合わせる
---@param bufnr integer
---@return {old: string, new: string}[]
local function compute_renames(bufnr)
    local candidates = vim.b[bufnr].fern_replacer_candidates
    if not candidates or #candidates == 0 then
        return {}
    end

    local new_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local renames = {}

    for i, old_path in ipairs(candidates) do
        local new_line = new_lines[i]
        if not new_line or new_line == "" then
            break
        end

        -- 新ファイル名が絶対パスならそのまま、そうでなければ旧パスの親ディレクトリと結合する
        local new_path = vim.startswith(new_line, "/") and new_line
            or (vim.fn.fnamemodify(old_path, ":h") .. "/" .. new_line)

        if old_path ~= new_path then
            table.insert(renames, { old = old_path, new = new_path })
        end
    end

    return renames
end

--- did_rename_files 通知とバッファ名の更新を行う (冪等)
---@param bufnr integer
local function flush_pending_renames(bufnr)
    local renames = pending_renames[bufnr]
    if not renames then
        return
    end
    pending_renames[bufnr] = nil

    -- 開いているバッファのパスを更新する
    for _, r in ipairs(renames) do
        for _, b in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_loaded(b) and vim.api.nvim_buf_get_name(b) == r.old then
                vim.api.nvim_buf_set_name(b, r.new)
                vim.api.nvim_buf_call(b, function()
                    vim.cmd("edit")
                end)
            end
        end
    end

    -- workspace/didRenameFiles を一括送信する
    local files = vim.tbl_map(function(r)
        return { oldUri = vim.uri_from_fname(r.old), newUri = vim.uri_from_fname(r.new) }
    end, renames)
    for _, client in ipairs(get_capable_clients("didRename")) do
        client:notify("workspace/didRenameFiles", { files = files })
    end
end

-- ----------------------------------------------------------------
-- fern の ftplugin 用キーマップ
-- ----------------------------------------------------------------

--- fern の cursor node の絶対パスを返す
---@return string|nil
local function fern_cursor_path()
    local ok, path = pcall(vim.api.nvim_eval, "fern#helper#new().sync.get_cursor_node()._path")
    return (ok and type(path) == "string" and #path > 0) and path or nil
end

--- fern で選択 (またはマーク) されているノードの絶対パスのリストを返す
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

-- ----------------------------------------------------------------
-- 公開セットアップ関数
-- ----------------------------------------------------------------

--- fern-replacer バッファの保存前後に LSP rename 通知を行う autocmd を登録する
--- vim-fern プラグインの lua_source (または lua_add) から一度だけ呼ぶこと
function M.setup()
    local augroup = vim.api.nvim_create_augroup("FernLspFileOps", { clear = true })

    -- 保存前: workspace/willRenameFiles を一括送信して workspace edit を適用する
    vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        callback = function(args)
            local bufnr = args.buf
            if vim.bo[bufnr].filetype ~= "fern-replacer" then
                return
            end

            local renames = compute_renames(bufnr)
            if #renames == 0 then
                return
            end

            local files = vim.tbl_map(function(r)
                return { oldUri = vim.uri_from_fname(r.old), newUri = vim.uri_from_fname(r.new) }
            end, renames)

            for _, client in ipairs(get_capable_clients("willRename")) do
                local result = client:request_sync("workspace/willRenameFiles", { files = files }, 1500)
                if result and not result.err and result.result then
                    apply_workspace_edit(result.result, client.offset_encoding)
                end
            end

            -- BufWritePost/BufUnload で参照できるよう保存する
            pending_renames[bufnr] = renames
        end,
    })

    -- 保存後: workspace/didRenameFiles を送信する
    -- BufWriteCmd 経由の場合も BufWritePost が発火するケースに対応する
    vim.api.nvim_create_autocmd("BufWritePost", {
        group = augroup,
        callback = function(args)
            if vim.bo[args.buf].filetype ~= "fern-replacer" then
                return
            end
            flush_pending_renames(args.buf)
        end,
    })

    -- fern が rename 後にバッファを閉じる場合の BufWritePost 非発火への対策
    vim.api.nvim_create_autocmd("BufUnload", {
        group = augroup,
        callback = function(args)
            if vim.bo[args.buf].filetype ~= "fern-replacer" then
                return
            end
            flush_pending_renames(args.buf)
        end,
    })
end

--- vim-fern バッファ用の LSP file operation キーマップを設定する
--- fern の ftplugin から呼び出すこと
function M.setup_keymaps()
    -- ファイル/ディレクトリのリネーム (r)
    -- fern ネイティブの rename action を使い、fern-replacer バッファ経由で LSP に通知する
    vim.keymap.set("n", "r", "<Plug>(fern-action-rename)", {
        buffer = true,
        desc = "Fern: rename (LSP 通知付き)",
    })

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

        M.will_delete_files(paths)

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
            M.did_delete_files(deleted)
        end

        fern_reload()
    end, { buffer = true, desc = "Fern: delete with LSP notification" })
end

return M
