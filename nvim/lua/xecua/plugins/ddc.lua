-- lua_add {{{
vim.keymap.set('i', '<Tab>', function()
  if vim.fn['vsnip#jumpable'](1) == 1 then
    return '<Plug>(vsnip-jump-next)'
  elseif vim.fn['pum#visible']() then
    return '<Cmd>call pum#map#insert_relative(1)<CR>'
  end
  local _, col = unpack(vim.api.nvim_win_get_cursor(0))
  local current_char = string.sub(vim.api.nvim_get_current_line(), 0, col)
  if string.match(current_char, '^%s*$') ~= nil then
    return '<Tab>'
  end
  return vim.fn['ddc#map#manual_complete']()
end, {
  expr = true,
  desc = 'Select next entry or start completion. At the head of line, feed <tab>',
})
vim.keymap.set('i', '<S-Tab>', function()
  if vim.fn['vsnip#jumpable'](-1) == 1 then
    return '<Plug>(vsnip-jump-prev)'
  elseif vim.fn['pum#visible']() then
    return '<Cmd>call pum#map#insert_relative(-1)<CR>'
  end
  local _, col = unpack(vim.api.nvim_win_get_cursor(0))
  local current_char = string.sub(vim.api.nvim_get_current_line(), 0, col)
  if string.match(current_char, '^%s*$') ~= nil then
    return '<C-h>'
  end
  return vim.fn['ddc#map#manual_complete']()
end, { expr = true, desc = 'Select previous entry, or feed <C-h>' })

vim.keymap.set('i', '<C-n>', function()
  if vim.fn['pum#visible']() then
    vim.fn['pum#map#insert_relative'](1, 'loop')
  else
    vim.fn['ddc#map#manual_complete']()
  end
end, { desc = 'Select next entry or start completion' })
vim.keymap.set('i', '<C-p>', function()
  if vim.fn['pum#visible']() then
    vim.fn['pum#map#insert_relative'](-1, 'loop')
  else
    vim.fn['ddc#map#manual_complete']()
  end
end, { desc = 'Select previous entry or start completion' })
vim.keymap.set('i', '<C-y>', '<Cmd>call pum#map#confirm()<CR>')
vim.keymap.set('i', '<C-c>', '<Cmd>call pum#map#cancel()<CR>')

-- }}}
-- lua_post_source {{{
vim.fn['ddc#custom#patch_global']('ui', 'pum')

vim.fn['ddc#custom#patch_global']('sources', {
  'lsp',
  'file',
  'skkeleton',
  'around',
  'vsnip',
  'copilot',
})
vim.fn['ddc#custom#patch_global']({
  sourceOptions = {
    _ = {
      matchers = { 'matcher_head' },
      sorters = { 'sorter_rank' },
      ignoreCase = true,
    },
    around = {
      mark = 'A',
      matchers = { 'matcher_fuzzy' },
      sorters = { 'sorter_fuzzy' },
      converters = { 'converter_fuzzy' },
    },
    vsnip = {
      mark = 'snip',
      dup = 'keep',
    },
    lsp = {
      mark = 'LSP',
      dup = 'keep',
      matchers = { 'matcher_fuzzy' },
      sorters = { 'sorter_fuzzy' },
      converters = { 'converter_fuzzy' },
      forceCompletionPattern = [[\.\w*|:\w*|->\w*]],
    },
    file = {
      mark = 'file',
      matchers = { 'matcher_fuzzy' },
      sorters = { 'sorter_fuzzy' },
      converters = { 'converter_fuzzy' },
      forceCompletionPattern = [[\S/\S*]],
    },
    skkeleton = {
      mark = 'skk',
      matchers = { 'skkeleton' },
      sorters = {},
      isVolatile = true,
    },
    copilot = {
      mark = 'copilot',
      matchers = {},
      isVolatile = true,
      enabledIf = 'copilot#Enabled()',
    },
  },
  sourceParams = {
    lsp = {
      snippetEngine = vim.fn['denops#callback#register'](function(body)
        vim.fn['vsnip#anonymous'](body)
      end),
      enableResolveItem = true,
      enableAdditionalTextEdit = true,
      confirmBehavior = 'replace',
    },
  },
})

-- ddc-file (windows)
vim.fn['ddc#custom#patch_filetype']({ 'ps1', 'dosbatch', 'autohotkey', 'registry' }, {
  sourceOptions = {
    file = {
      forceCompletionPattern = [[\S\\\S*]],
    },
  },
  sourceParams = {
    file = {
      mode = 'win32',
    },
  },
})

vim.fn['ddc#enable']()
-- }}}
