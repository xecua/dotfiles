-- lua_add {{{
vim.keymap.set({ "i", "c" }, "<Tab>", function()
    if vim.fn["denippet#jumpable"](1) then
        return "<Plug>(denippet-jump-next)"
    elseif vim.fn["pum#visible"]() then
        return "<Cmd>call pum#map#insert_relative(1)<CR>"
    end
    local _, col = unpack(vim.api.nvim_win_get_cursor(0))
    local current_char = string.sub(vim.api.nvim_get_current_line(), 0, col)
    if string.match(current_char, "^%s*$") ~= nil then
        return "<Tab>"
    end
    return vim.fn["ddc#map#manual_complete"]()
end, {
    expr = true,
    desc = "Select next entry or start completion. At the head of line, feed <tab>",
})
vim.keymap.set({ "i", "c" }, "<S-Tab>", function()
    if vim.fn["denippet#jumpable"](-1) then
        return "<Plug>(denippet-jump-prev)"
    elseif vim.fn["pum#visible"]() then
        return "<Cmd>call pum#map#insert_relative(-1)<CR>"
    end
    local _, col = unpack(vim.api.nvim_win_get_cursor(0))
    local current_char = string.sub(vim.api.nvim_get_current_line(), 0, col)
    if string.match(current_char, "^%s*$") ~= nil then
        return "<C-h>"
    end
    return vim.fn["ddc#map#manual_complete"]()
end, { expr = true, desc = "Select previous entry, or feed <C-h>" })

vim.keymap.set({ "i", "c" }, "<C-n>", function()
    if vim.fn["pum#visible"]() then
        vim.fn["pum#map#insert_relative"](1, "loop")
    else
        vim.fn["ddc#map#manual_complete"]()
    end
end, { desc = "Select next entry or start completion" })
vim.keymap.set({ "i", "c" }, "<C-p>", function()
    if vim.fn["pum#visible"]() then
        vim.fn["pum#map#insert_relative"](-1, "loop")
    else
        vim.fn["ddc#map#manual_complete"]()
    end
end, { desc = "Select previous entry or start completion" })
vim.keymap.set({ "i", "c" }, "<C-y>", "<Cmd>call pum#map#confirm()<CR>")
vim.keymap.set({ "i", "c" }, "<C-c>", "<Cmd>call pum#map#cancel()<CR>")
-- }}}

-- lua_source {{{
vim.lsp.config("*", {
    capabilities = require("ddc_source_lsp").make_client_capabilities(),
})
vim.fn["ddc#custom#load_config"](vim.fn.stdpath("config") .. "/dpp/ddc.ts")

vim.keymap.set({ "n", "v" }, ":", function()
    vim.fn["pum#set_option"]({
        reversed = true,
        direction = "above",
    })

    vim.api.nvim_create_autocmd("User", {
        pattern = "DDCCmdlineLeave",
        once = true,
        callback = function()
            vim.fn["pum#set_option"]({
                reversed = false,
                direction = "auto",
            })
        end,
    })

    vim.fn["ddc#enable_cmdline_completion"]()
    return ":"
end, { expr = true })

vim.fn["ddc#enable_terminal_completion"]()
vim.fn["ddc#enable"]({ context_filetype = "treesitter" })
-- }}}
