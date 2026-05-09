local M = {}

local buf = nil
local win = nil
local timer = nil

local HEIGHT = 3
local WIDTH = 10 -- "  HH:MM  "

local function get_lines()
    local time = vim.fn.strftime("%H:%M")
    local pad = string.rep(" ", WIDTH)
    local line = "  " .. time .. "   "
    return { pad, line, pad }
end

local function win_opts()
    -- Place above the global statusline (laststatus=3 takes the last row)
    local row = vim.o.lines - vim.o.cmdheight - HEIGHT - 1
    local col = vim.o.columns - WIDTH - 1
    return {
        relative = "editor",
        row = row,
        col = col,
        width = WIDTH,
        height = HEIGHT,
        style = "minimal",
        focusable = false,
        zindex = 10,
    }
end

local function update()
    if not (buf and vim.api.nvim_buf_is_valid(buf)) then
        return
    end
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, get_lines())
end

local function set_hl()
    vim.api.nvim_set_hl(0, "ClockNormal", { fg = "#999999", bg = "NONE" })
end

function M.setup()
    set_hl()

    buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].bufhidden = "hide"

    win = vim.api.nvim_open_win(buf, false, win_opts())
    vim.wo[win].winblend = 70
    vim.wo[win].winhighlight = "Normal:ClockNormal,NormalFloat:ClockNormal"
    vim.wo[win].number = false
    vim.wo[win].relativenumber = false
    vim.wo[win].cursorline = false
    vim.wo[win].signcolumn = "no"

    update()

    local augroup = vim.api.nvim_create_augroup("ClockWidget", { clear = true })

    vim.api.nvim_create_autocmd("ColorScheme", {
        group = augroup,
        callback = set_hl,
    })

    vim.api.nvim_create_autocmd("VimResized", {
        group = augroup,
        callback = function()
            if win and vim.api.nvim_win_is_valid(win) then
                vim.api.nvim_win_set_config(win, win_opts())
            end
        end,
    })

    -- Update every 30 seconds; minute granularity is sufficient
    timer = (vim.uv or vim.loop).new_timer()
    timer:start(0, 30000, vim.schedule_wrap(function()
        if not (buf and vim.api.nvim_buf_is_valid(buf)) then
            timer:stop()
            return
        end
        update()
    end))
end

return M
