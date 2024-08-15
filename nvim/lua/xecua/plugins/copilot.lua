-- lua_add {{{
vim.g.copilot_filetypes = {
  ['*'] = true,
  ['dap-repl'] = false,
  markdown = false,
  dapui_watches = false,
  dapui_scopes = false,
  dapui_console = false,
  ['ddu-ff-filter'] = false,
}

vim.keymap.set('i', '<C-l>', 'copilot#Accept("<C-l>")', { replace_keycodes = false, silent = true, expr = true })
vim.g.copilot_no_tab_map = true
-- }}}
