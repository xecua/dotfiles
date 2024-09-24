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
-- }}}
