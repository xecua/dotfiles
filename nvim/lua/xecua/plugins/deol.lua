-- lua_add {{{
vim.g['deol#floating_border'] = 'single'
vim.g['deol#custom_map'] = {
  next_prompt = '<C-j>',
  previous_prompt = '<C-k>',
}

vim.keymap.set('n', '<Leader>p', function()
  vim.fn['deol#start']({
    wincol = math.floor(vim.o.column / 18),
    winwidth = math.floor(vim.o.columns * 8 / 9),
    winrow = math.floor(vim.o.lines / 18),
    winheight = math.floor(vim.o.lines * 8 / 9),
    toggle = true,
    split = 'floating',
  })
end)
-- }}}
