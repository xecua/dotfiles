-- goda-cmp の snippet ソースから呼ぶ mini.snippets のヘルパ
local M = {}

--- 現在のバッファ・カーソル位置で使えるスニペットを返す
--- @return { prefix: string, body: string, desc: string }[]
function M.items()
    local MiniSnippets = _G.MiniSnippets
    if MiniSnippets == nil then
        return {}
    end
    local ok, snips = pcall(MiniSnippets.expand, { match = false, insert = false })
    if not ok or type(snips) ~= "table" then
        return {}
    end
    local ret = {}
    for _, s in ipairs(snips) do
        if type(s.prefix) == "string" and s.prefix ~= "" and type(s.body) == "string" then
            local desc = s.desc
            if type(desc) == "table" then
                desc = table.concat(desc, " ")
            end
            table.insert(ret, { prefix = s.prefix, body = s.body, desc = type(desc) == "string" and desc or "" })
        end
    end
    return ret
end

--- 確定した prefix をカーソル直前から消し、body をスニペットとして挿入する
--- @param prefix string
--- @param body string
function M.expand(prefix, body)
    -- 補完確定の処理中に呼ばれるので、終わってから書き換える
    vim.schedule(function()
        local MiniSnippets = _G.MiniSnippets
        if MiniSnippets == nil or vim.fn.mode() ~= "i" then
            return
        end
        local cursor = vim.api.nvim_win_get_cursor(0)
        local row, col = cursor[1], cursor[2]
        local line = vim.api.nvim_get_current_line()
        local start = col - #prefix
        if start < 0 or line:sub(start + 1, col) ~= prefix then
            return
        end
        vim.api.nvim_buf_set_text(0, row - 1, start, row - 1, col, {})
        vim.api.nvim_win_set_cursor(0, { row, start })
        MiniSnippets.default_insert({ body = body })
    end)
end

return M
