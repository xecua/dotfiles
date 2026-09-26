local augroup = vim.api.nvim_create_augroup("xecua_langswitch", { clear = true })
local filetype = require("xecua.filetype")

local buf_last_lang = {}

local function on_lang_change(buf, lang)
    if lang == "comment" then
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
