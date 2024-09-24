-- lua_add {{{
-- cannot use submode.vim to enter submode

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
    if not is_submode then
        is_submode = true
        vim.keymap.set("n", "h", function()
            handle_key("h")
        end, {})
        vim.keymap.set("n", "j", function()
            handle_key("j")
        end, {})
        vim.keymap.set("n", "k", function()
            handle_key("k")
        end, {})
        vim.keymap.set("n", "l", function()
            handle_key("l")
        end, {})
        vim.keymap.set("n", "<Esc>", function()
            handle_key("<Esc>")
        end, {})
    end
end

handle_key = function(key)
    if vim.b.rbcsv ~= 1 then
        leave_submode()
        vim.fn.feedkeys(key)
        return
    end

    enter_submode()

    if key == "h" then
        vim.cmd("RainbowCellGoLeft")
    elseif key == "j" then
        vim.cmd("RainbowCellGoDown")
    elseif key == "k" then
        vim.cmd("RainbowCellGoUp")
    elseif key == "l" then
        vim.cmd("RainbowCellGoRight")
    else
        leave_submode()
        vim.fn.feedkeys(key)
    end
end

vim.keymap.set("n", "<Leader>rh", function()
    handle_key("h")
end, { desc = "Entering CSV Move Mode" })
vim.keymap.set("n", "<Leader>rj", function()
    handle_key("j")
end, { desc = "Entering CSV Move Mode" })
vim.keymap.set("n", "<Leader>rk", function()
    handle_key("k")
end, { desc = "Entering CSV Move Mode" })
vim.keymap.set("n", "<Leader>rl", function()
    handle_key("l")
end, { desc = "Entering CSV Move Mode" })

-- }}}
