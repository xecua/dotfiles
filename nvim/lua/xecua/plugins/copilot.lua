vim.g.copilot_filetypes = {
  ['*'] = true,
  ['dap-repl'] = false,
  ['dapui_*'] = false,
}

vim.keymap.set('i', '<C-k>', 'copilot#Accept("<C-k>")', { replace_keycodes = false, silent = true, expr = true })
vim.g.copilot_no_tab_map = true
