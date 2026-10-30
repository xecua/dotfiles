-- lua_add {{{
vim.api.nvim_create_autocmd("VimEnter", {
    command = "call goda_cmp#enable()",
})
vim.api.nvim_create_user_command("GodaCmpBuild", "call goda_cmp#build()")
local function do_completion(delta)
    return function()
        if vim.fn["pum#visible"]() then
            if delta < 0 and not vim.fn["pum#entered"]() then
                vim.fn["pum#map#insert_relative"](delta, "loop")
            else
                vim.fn["pum#map#insert_relative"](delta)
            end
        else
            vim.fn["goda_cmp#complete"]()
        end
    end
end
vim.keymap.set("c", "<Tab>", do_completion(1), { desc = "Select next entry or start completion." })
vim.keymap.set("c", "<S-Tab>", do_completion(-1), { desc = "Select previous entry or start completion." })
vim.keymap.set({ "i", "c" }, "<C-n>", do_completion(1), { desc = "Select next entry or start completion" })
vim.keymap.set({ "i", "c" }, "<C-p>", do_completion(-1), { desc = "Select previous entry or start completion" })
vim.keymap.set({ "i", "c" }, "<C-y>", "<Cmd>call pum#map#confirm()<CR>")
vim.keymap.set({ "i", "c" }, "<C-c>", "<Cmd>call pum#map#cancel()<CR>")
vim.keymap.set({ "i", "c", "t" }, "<LeftMouse>", function()
    if vim.fn["pum#visible"]() then
        return "<Cmd>call pum#map_confirm_mouse()<CR>"
    else
        return "<LeftMouse>"
    end
end, { expr = true, desc = "Confirm completion item with mouse" })
vim.keymap.set({ "n", "v" }, ":", function()
    vim.fn["pum#set_option"]({
        reversed = true,
        direction = "above",
    })

    vim.api.nvim_create_autocmd("User", {
        pattern = "GodaCmpCmdlineLeave",
        once = true,
        callback = function()
            vim.fn["pum#set_option"]({
                reversed = false,
                direction = "auto",
            })
        end,
    })

    vim.fn["goda_cmp#enable_cmdline"]()
    return ":"
end, { expr = true })

-- }}}
