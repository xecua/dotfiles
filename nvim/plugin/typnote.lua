local dir = vim.g.typnote_dir

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
    local year = os.date("%Y", t)
    local path = ("%s/%s/%s.typ"):format(dir, year, os.date("%Y-%m-%d", t))
    vim.fn.mkdir(dir, "p")
    vim.cmd.edit(vim.fn.fnameescape(path))
    if vim.fn.filereadable(path) == 0 then
        vim.api.nvim_buf_set_lines(
            0,
            0,
            -1,
            false,
            { '#import "../template.typ": daily', "", "= " .. os.date("%Y-%m-%d", t), "" }
        )
    end
end

vim.api.nvim_create_user_command("TypToday", function()
    open_daily(0)
end, {})
vim.api.nvim_create_user_command("TypYesterday", function()
    open_daily(-1, true)
end, {})
vim.api.nvim_create_user_command("TypTomorrow", function()
    open_daily(1, true)
end, {})
