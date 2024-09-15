-- lua_post_source {{{
require('tabnine').setup({
  accept_keymap = false,
  dismiss_keymap = false,
  suggestion_color = { gui = '#555555', cterm = 8 }, -- same as copilot.vim
  exclude_filetypes = {
    'dap-repl',
    'markdown',
    'dapui_watches',
    'dapui_scopes',
    'dapui_console',
  },
})

vim.keymap.set('i', '<C-l>', function()
  if require('tabnine.keymaps').has_suggestion() then
    return require('tabnine.keymaps').accept_suggestion()
  else
    return '<C-l>'
  end
end, { expr = true })
-- }}}
