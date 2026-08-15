-- lua_add {{{
vim.keymap.set("i", "<Tab>", "denippet#jumpable(1) ? '<Plug>(denippet-jump-next)' : '<Tab>'", {
    expr = true,
    desc = "Jump to next placeholder, or feed <Tab>",
})
vim.keymap.set(
    "i",
    "<S-Tab>",
    "denippet#jumpable(-1) ? '<Plug>(denippet-jump-prev)' : '<C-h>'",
    { expr = true, desc = "Jump to previous placeholder, or feed <C-h>" }
)
local function do_completion(delta)
    return function()
        if vim.fn["pum#visible"]() then
            vim.fn["pum#map#insert_relative"](delta)
        else
            vim.fn["ddc#map#manual_complete"]()
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
