-- lua_post_source {{{
vim.fn["lexima#add_rule"]({ char = "(", at = [[\\\%#]], input_after = "\\)", filetype = "tex" })
vim.fn["lexima#add_rule"]({ char = "<BS>", at = [[\\(\%#\\)]], delete = 2, input = "<BS><BS>", filetype = "tex" })
vim.fn["lexima#add_rule"]({ char = "[", at = [[\\\%#]], input_after = "\\]", filetype = "tex" })
vim.fn["lexima#add_rule"]({ char = "<BS>", at = [=[\\\[\%#\\]]=], delete = 2, input = "<BS><BS>", filetype = "tex" })
-- move cursor to right by 1(leave), then insert two single-quotes(input_after)
vim.fn["lexima#add_rule"]({ char = "`", at = [[`\%#`]], leave = 1, input_after = "''", filetype = "tex" })
vim.fn["lexima#add_rule"]({ char = "<BS>", at = [[``\%#'']], delete = 2, input = "<BS><BS>", filetype = "tex" })
vim.fn["lexima#add_rule"]({
    char = "[",
    at = [=[\[\(=\+\)\%#\]]=],
    input_after = [=[]\1]=],
    with_submatch = true,
    filetype = "lua",
})

-- <CR>でもpum.vimの確定ができるようにする
vim.keymap.set("i", "<CR>", function()
    if vim.fn["pum#entered"]() then
        return "<Cmd>call pum#map#confirm()<CR>"
    else
        return '<C-r>=lexima#expand("<LT><CR>", "i")<CR>'
    end
end, { expr = true, silent = true })

-- }}}
