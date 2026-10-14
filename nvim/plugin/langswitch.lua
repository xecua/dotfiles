local augroup = vim.api.nvim_create_augroup("xecua_langswitch", { clear = true })
local filetype = require("xecua.filetype")

local buf_last_lang = {}

local SID_MODELINE = -1

-- editorconfigやmodelineでインデント設定が明示されているバッファでは触らない
local function has_local_indent_config(buf)
    local ec = vim.b[buf].editorconfig
    if type(ec) == "table" and (ec.indent_style or ec.indent_size or ec.tab_width) then
        return true
    end
    for _, name in ipairs({ "expandtab", "shiftwidth", "tabstop", "softtabstop" }) do
        local info = vim.api.nvim_get_option_info2(name, { buf = buf })
        if info.last_set_sid == SID_MODELINE then
            return true
        end
    end
    return false
end

local function on_lang_change(buf, lang)
    if lang == "comment" or has_local_indent_config(buf) then
        return
    end
    filetype.configure_indent_by_lang(lang)
end

local function update_lang()
    local parser = vim.treesitter.get_parser(0)
    if not parser then
        return
    end

    parser:parse()

    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local currentParser = parser:language_for_range({ row - 1, col, row - 1, col })
    local currentLang = currentParser:lang()

    local buf = vim.api.nvim_get_current_buf()
    if currentLang == buf_last_lang[buf] then
        return
    end
    buf_last_lang[buf] = currentLang

    on_lang_change(buf, currentLang)
end

vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "BufEnter" }, {
    group = augroup,
    pattern = "*",
    callback = function(args)
        vim.schedule(function()
            if args.buf == vim.api.nvim_get_current_buf() then
                update_lang()
            end
        end)
    end,
})

vim.api.nvim_create_autocmd("BufWipeout", {
    callback = function(args)
        buf_last_lang[args.buf] = nil
    end,
})
