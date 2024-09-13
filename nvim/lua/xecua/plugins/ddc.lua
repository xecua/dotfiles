-- lua_add {{{
vim.keymap.set('i', '<Tab>', function()
  if vim.fn['denippet#jumpable'](1) then
    return '<Plug>(denippet-jump-next)'
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
  if vim.fn['denippet#jumpable'](-1) then
    return '<Plug>(denippet-jump-prev)'
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
vim.fn['ddc#custom#patch_global']({
  ui = 'pum',
  sources = {
    'lsp',
    'file',
    'skkeleton',
    'around',
    'denippet',
  },
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
    denippet = {
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
    cmdline = { mark = 'cmd' },
    ['cmdline-history'] = { mark = 'cmd-hist' },
    input = { mark = 'input', isVolatile = true },
    line = { mark = 'line' },
    skkeleton = {
      mark = 'skk',
      matchers = {},
      sorters = {},
      isVolatile = true,
    },
  },
  sourceParams = {
    lsp = {
      snippetEngine = vim.fn['denops#callback#register'](function(body)
        vim.fn['denippet#anonymous'](body)
      end),
      enableResolveItem = true,
      enableAdditionalTextEdit = true,
      confirmBehavior = 'replace',
    },
  },
  autoCompleteEvents = { 'InsertEnter', 'TextChangedI', 'TextChangedP', 'CmdlineChanged' },
  cmdlineSources = {
    [':'] = { 'cmdline', 'cmdline-history', 'around' },
    ['@'] = { 'cmdline-history', 'input', 'file', 'around' },
    ['>'] = { 'cmdline-history', 'input', 'file', 'around' },
    ['/'] = { 'around', 'line' },
    ['?'] = { 'around', 'line' },
    ['-'] = { 'around', 'line' },
    ['='] = { 'input' },
  }
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

vim.keymap.set('n', ':', function()
  vim.keymap.set('c', '<Tab>', '<Cmd>call pum#map#insert_relative(+1)<CR>')
  vim.keymap.set('c', '<S-Tab>', '<Cmd>call pum#map#insert_relative(-1)<CR>')
  vim.keymap.set('c', '<C-n>', '<Cmd>call pum#map#insert_relative(+1)<CR>')
  vim.keymap.set('c', '<C-p>', '<Cmd>call pum#map#insert_relative(-1)<CR>')
  vim.keymap.set('c', '<C-y>', '<Cmd>call pum#map#confirm()<CR>')
  vim.keymap.set('c', '<C-e>', '<Cmd>call pum#map#cancel()<CR>')
  vim.fn['pum#set_option']('reversed', true)

  vim.api.nvim_create_autocmd('User', {
    pattern = 'DDCCmdlineLeave',
    once = true,
    callback = function()
      vim.keymap.del('c', '<Tab>')
      vim.keymap.del('c', '<S-Tab>')
      vim.keymap.del('c', '<C-n>')
      vim.keymap.del('c', '<C-p>')
      vim.keymap.del('c', '<C-y>')
      vim.keymap.del('c', '<C-e>')
      vim.fn['pum#set_option']('reversed', false)
    end
  })

  vim.fn['ddc#enable_cmdline_completion']()
  return ':'
end, { expr = true })

vim.fn['ddc#enable']()
-- }}}
