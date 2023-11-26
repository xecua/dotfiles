local utils = require('xecua.utils')

vim.g.mapleader = vim.api.nvim_replace_termcodes('<Space>', true, true, true)

vim.g.vimsyn_embed = 'l'
vim.g.tex_flavor = 'latex'
vim.g.tex_conceal = ''
vim.g.terminal_color_0 = '#2e2e2e'
vim.g.terminal_color_1 = '#eb4129'
vim.g.terminal_color_2 = '#abe047'
vim.g.terminal_color_3 = '#f6c744'
vim.g.terminal_color_4 = '#47a0f3'
vim.g.terminal_color_5 = '#7b5cb0'
vim.g.terminal_color_6 = '#64dbed'
vim.g.terminal_color_7 = '#e5e9f0'
vim.g.terminal_color_8 = '#565656'
vim.g.terminal_color_9 = '#ec5357'
vim.g.terminal_color_10 = '#c0e17d'
vim.g.terminal_color_11 = '#f9da6a'
vim.g.terminal_color_12 = '#49a4f8'
vim.g.terminal_color_13 = '#a47de9'
vim.g.terminal_color_14 = '#99faf2'
vim.g.terminal_color_15 = '#ffffff'

if utils.get_os_string() == 'WSL' then
  -- :h g:clipboard
  vim.g.clipboard = {
    name = 'WslClipboard',
    copy = {
      ['+'] = 'win32yank.exe -i',
      ['*'] = 'win32yank.exe -i',
    },
    paste = {
      ['+'] = 'win32yank.exe -o',
      ['*'] = 'win32yank.exe -o',
    },
    cache_enabled = 0,
  }
end
