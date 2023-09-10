vim.g.copilot_filetypes = {
  ['*'] = true,
  ['dap-repl'] = false,
  ['dapui_*'] = false,
  ['ddu*'] = false,
}

vim.keymap.set('i', '<C-l>', 'copilot#Accept("<C-l>")', { replace_keycodes = false, silent = true, expr = true })
vim.g.copilot_no_tab_map = true
