vim.g['deol#floating_border'] = 'single'
vim.g['deol#custom_map'] = {
  next_prompt = '<C-j>',
  previous_prompt = '<C-k>',
}

vim.keymap.set('n', '<Leader>p', function()
  local height = math.floor(vim.o.lines / 2)
  local width = math.floor(vim.o.columns / 2)
  vim.cmd('Deol -toggle -split=floating -winheight=' .. height .. ' -winwidth=' .. width)
end)
