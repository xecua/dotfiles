-- lua_add {{{

-- <-- floating terminal
local buf = nil
local win = nil

local ddt_group_id = vim.api.nvim_create_augroup("DdtMyCnf", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
    group = ddt_group_id,
    pattern = "ddt-terminal",
    callback = function()
        -- bufとwinをいじるのでここは必要
        if buf ~= nil and win ~= nil then
            return
        end
        vim.api.nvim_create_autocmd("BufLeave", {
            buffer = 0,
            callback = function()
                pcall(vim.api.nvim_win_close, win, true)
                buf = nil
                win = nil
            end,
        })
    end,
})

local function ddt_float_term_toggle()
    -- darken background
    if buf == nil then
        buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
        win = vim.api.nvim_open_win(buf, true, {
            relative = "editor",
            width = vim.o.columns,
            height = vim.o.lines,
            col = 0,
            row = 0,
            focusable = false,
            style = "minimal",
        })
        vim.api.nvim_set_option_value("winblend", 50, { scope = "local", win = win })
        vim.fn["ddt#start"]({
            uiParams = {
                terminal = {
                    split = "floating",
                    winCol = vim.o.columns / 18,
                    winWidth = vim.o.columns * 8 / 9,
                    winRow = vim.o.lines / 18,
                    winHeight = math.floor(vim.o.lines * 8 / 9),
                },
            },
        })
    else
        vim.api.nvim_win_close(vim.g.ddt_ui_last_winid, true)
    end
end

vim.api.nvim_create_user_command("DdtFloatTermToggle", ddt_float_term_toggle, {})
vim.keymap.set("n", "<Leader>p", "<Cmd>DdtFloatTermToggle<CR>")
-- -->

-- <-- terminal on bottom
local function ddt_bottom_term()
    vim.fn["ddt#start"]({
        uiParams = {
            terminal = { split = "horizontal", winHeight = 10 },
        },
    })
end
vim.api.nvim_create_user_command("DdtBottomTerm", ddt_bottom_term, {})
vim.keymap.set("n", "<Leader>`", "<Cmd>DdtBottomTerm<CR>")
-- }}}

-- lua_source {{{
local is_darwin = require("xecua.utils").get_os_string() == "Darwin"

vim.fn["ddt#custom#patch_global"]({
    ui = "terminal",
    uiParams = {
        terminal = {
            toggle = true,
            command = is_darwin and "zsh" or "bash",
            startInsert = true,
        },
    },
})
-- }}}

-- lua_ddt-terminal {{{
vim.keymap.set("n", "<CR>", "<Cmd>call ddt#ui#do_action('executeLine')<CR>", { buffer = true })
-- }}}
