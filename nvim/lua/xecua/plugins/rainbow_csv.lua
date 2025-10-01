-- lua_add {{{
-- cannot use submode.vim because it is not resolved for each key press

local leave_submode, handle_key, enter_submode
local is_submode = false

leave_submode = function()
    if is_submode then
        is_submode = false
        vim.keymap.del("n", "h", {})
        vim.keymap.del("n", "j", {})
        vim.keymap.del("n", "k", {})
        vim.keymap.del("n", "l", {})
        vim.keymap.del("n", "<Esc>", {})
    end
end

enter_submode = function()
    vim.keymap.set("n", "h", handle_key("h"), { buffer = true, desc = "Move to Left" })
    vim.keymap.set("n", "j", handle_key("j"), { buffer = true, desc = "Move to Down" })
    vim.keymap.set("n", "k", handle_key("k"), { buffer = true, desc = "Move to Up" })
    vim.keymap.set("n", "l", handle_key("l"), { buffer = true, desc = "Move to Right" })
    vim.keymap.set("n", "<Esc>", leave_submode, { buffer = true, desc = "Leave move mode" })
end

handle_key = function(key)
    return function()
        if not is_submode then
            is_submode = true
            enter_submode()
        end

        if key == "h" then
            vim.cmd("RainbowCellGoLeft")
        elseif key == "j" then
            vim.cmd("RainbowCellGoDown")
        elseif key == "k" then
            vim.cmd("RainbowCellGoUp")
        elseif key == "l" then
            vim.cmd("RainbowCellGoRight")
        end
    end
end

vim.keymap.set("n", "<Leader>rh", handle_key("h"), { buffer = true, desc = "Enter move mode then move to left" })
vim.keymap.set("n", "<Leader>rj", handle_key("j"), { buffer = true, desc = "Enter move mode then move to down" })
vim.keymap.set("n", "<Leader>rk", handle_key("k"), { buffer = true, desc = "Enter move mode then move to up" })
vim.keymap.set("n", "<Leader>rl", handle_key("l"), { buffer = true, desc = "Enter move mode then move to right" })

-- }}}
