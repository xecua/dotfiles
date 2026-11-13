-- markdown-oxide の :LspToday 等は markdown バッファでしか使えず、テンプレートも無いので自前で開く
-- vim.g.mdnote_dir: vault のルート
-- vim.g.mdnote_daily_format: vault からのパス (os.date の書式、拡張子なし。.obsidian/daily-notes.json の folder/format に合わせる)
-- vim.g.mdnote_daily_template: 新規作成時に流し込むファイル (vault からの相対パス)。{{date}} {{time}} {{title}} を置換
local dir = vim.g.mdnote_dir

if dir == nil then
    return
end

local function open_daily(offset, workday)
    local t = os.time()
    local step = offset < 0 and -1 or 1
    local n = math.abs(offset)
    while n > 0 do
        t = t + step * 86400
        local wday = os.date("*t", t).wday -- 1=日, 7=土
        if not workday or (wday ~= 1 and wday ~= 7) then
            n = n - 1
        end
    end
    local format = vim.g.mdnote_daily_format or "dailynotes/%Y/%Y-%m-%d"
    local path = ("%s/%s.md"):format(dir, os.date(format, t))
    local is_new = vim.fn.filereadable(path) == 0
    vim.fn.mkdir(vim.fs.dirname(path), "p")
    vim.cmd.edit(vim.fn.fnameescape(path))

    local template = vim.g.mdnote_daily_template and (dir .. "/" .. vim.g.mdnote_daily_template)
    if is_new and template and vim.fn.filereadable(template) == 1 then
        local vars = {
            date = os.date("%Y-%m-%d", t),
            time = os.date("%H:%M"),
            title = vim.fn.fnamemodify(path, ":t:r"),
        }
        local lines = vim.tbl_map(function(line)
            return (line:gsub("{{(%w+)}}", vars))
        end, vim.fn.readfile(template))
        vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    end
end

vim.api.nvim_create_user_command("MdToday", function()
    open_daily(0)
end, {})
vim.api.nvim_create_user_command("MdYesterday", function()
    open_daily(-1, true)
end, {})
vim.api.nvim_create_user_command("MdTomorrow", function()
    open_daily(1, true)
end, {})
