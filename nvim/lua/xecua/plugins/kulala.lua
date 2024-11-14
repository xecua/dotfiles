-- lua_add {{{
vim.filetype.add({
    extension = {
        ["http"] = "http",
    },
})

vim.keymap.set(
    "n",
    "<Leader>ks",
    '<Cmd>lua require("kulala").scratchpad()<CR>',
    { silent = true, desc = "Open http scratchpad" }
)

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "http" },
    callback = function()
        vim.keymap.set(
            "n",
            "<CR>",
            '<Cmd>lua require("kulala").run()<CR>',
            { silent = true, buffer = true, desc = "Execute the request" }
        )

        vim.keymap.set(
            "n",
            "[",
            '<Cmd>lua require("kulala").jump_prev()<CR>',
            { silent = true, buffer = true, desc = "Jump to the previous request" }
        )
        vim.keymap.set(
            "n",
            "]",
            '<Cmd>lua require("kulala").jump_next()<CR>',
            { silent = true, buffer = true, desc = "Jump to the next request" }
        )

        vim.keymap.set(
            "n",
            "<Leader>ki",
            '<Cmd>lua require("kulala").inspect()<CR>',
            { silent = true, buffer = true, desc = "Insert current request" }
        )
        vim.keymap.set(
            "n",
            "<Leader>kt",
            '<Cmd>lua require("kulala").toggle_view()<CR>',
            { silent = true, buffer = true, desc = "Toggle between body and headers" }
        )
        vim.keymap.set(
            "n",
            "<Leader>kc",
            '<Cmd>lua require("kulala").copy()<CR>',
            { silent = true, buffer = true, desc = "Copy current request as curl command" }
        )
        vim.keymap.set(
            "n",
            "<Leader>kp",
            '<Cmd>lua require("kulala").from_curl()<CR>',
            { silent = true, buffer = true, desc = "Paste from curl command in current clipboard" }
        )
    end,
})
-- }}}
