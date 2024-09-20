vim.g.neovide_input_ime = false
vim.g.neovide_scale_factor = 1.0
vim.g.neovide_cursor_vfx_mode = 'torpedo'
local function change_scale_factor(delta)
  vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * delta
end
vim.keymap.set('n', '<C-0>', function()
  change_scale_factor(1 / vim.g.neovide_scale_factor)
end)
vim.keymap.set('n', '<C-+>', function()
  change_scale_factor(1.25)
end)
vim.keymap.set('n', '<C-->', function()
  change_scale_factor(1 / 1.25)
end)
vim.api.nvim_create_user_command('NeovideToggleFullscreen', function()
  vim.g.neovide_fullscreen = not vim.g.neovide_fullscreen
end, {})

vim.env.COLORTERM = 'truecolor'

-- Neovideの場合、オプションは最後にくっついて全部のフォントに適用される あと'monospace'は解決してくれない
vim.opt.guifont = 'UDEV Gothic 35NFLG:h8'
