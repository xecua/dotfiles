-- lua_add {{{
-- vim.g.loaded_ddu_rg = 1 -- prevent command definition by plugin

vim.api.nvim_create_user_command('DduRgLive', function()
  vim.fn['ddu#start']({
    sources = { { name = 'rg', options = { volatile = true, matchers = {} } } },
    uiParams = { ff = { ignoreEmpty = false } },
  })
end, {})
vim.api.nvim_create_user_command('DduLspDocumentSymbol', function()
  vim.fn['ddu#start']({
    sources = { { name = 'lsp_documentSymbol' } },
    uiParams = { ff = { ignoreEmpty = false, displayTree = true } },
  })
end, {})
vim.api.nvim_create_user_command('DduLspWorkspaceSymbol', function()
  vim.fn['ddu#start']({
    sources = { { name = 'lsp_workspaceSymbol', options = { volatile = true } } },
    uiParams = { ff = { ignoreEmpty = false, displayTree = true } },
  })
end, {})
vim.keymap.set('n', '<Leader>fd', '<Cmd>Ddu file_fd<CR>')
vim.keymap.set('n', '<Leader>fb', '<Cmd>Ddu buffer<CR>')
vim.keymap.set('n', '<Leader>fg', '<Cmd>DduRgLive<CR>')
vim.keymap.set('n', '<Leader>fls', '<Cmd>DduLspDocumentSymbol<CR>')
vim.keymap.set('n', '<Leader>flw', '<Cmd>DduLspWorkspaceSymbol<CR>')
vim.keymap.set('n', '<Leader>c', '<Cmd>Ddu command<CR>')

local ddu_group_id = vim.api.nvim_create_augroup('DduMyCnf', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  group = ddu_group_id,
  pattern = 'ddu-ff',
  callback = function()
    local opts = { buffer = true, silent = true }
    vim.keymap.set('n', '<CR>', "<Cmd>call ddu#ui#do_action('itemAction')<CR>", opts)
    vim.keymap.set('n', 'a', "<Cmd>call ddu#ui#do_action('chooseAction')<CR>", opts)
    vim.keymap.set('n', '/', "<Cmd>call ddu#ui#do_action('openFilterWindow')<CR>", opts)
    vim.keymap.set('n', 'p', "<Cmd>call ddu#ui#do_action('togglePreview')<CR>", opts)
    vim.keymap.set('n', ',', "<Cmd>call ddu#ui#do_action('toggleSelectItem')<CR>", opts)
    vim.keymap.set('n', 't', "<Cmd>call ddu#ui#do_action('toggleAllItems')<CR>", opts)
    vim.keymap.set('n', 'f', "<Cmd>call ddu#ui#do_action('itemAction', { 'name': 'quickfix' })<CR>", opts)
    vim.keymap.set('n', 'q', "<Cmd>call ddu#ui#do_action('quit')<CR>", opts)

    -- ↓2つはmatcherが高々2つであることを仮定してる
    local converter_display_word = 'converter_display_word'
    local matcher_fzf = 'matcher_fzf'
    local matcher_substring = 'matcher_substring'
    vim.keymap.set('n', 'w', function()
      local matchers = vim.fn['ddu#custom#get_current'](vim.b.ddu_ui_name)['sourceOptions']['_']['matchers']

      if matchers[1] == converter_display_word then
        table.remove(matchers, 1)
        vim.notify('Display word excluded.')
      else
        table.insert(matchers, 1, converter_display_word)
        vim.notify('Display word included.')
      end

      vim.fn['ddu#ui#do_action']('updateOptions', { sourceOptions = { _ = { matchers = matchers } } })
      vim.fn['ddu#ui#do_action']('redraw', { method = 'refreshItems' })
    end, opts)
    vim.keymap.set('n', 's', function()
      -- toggle fuzzy/substring search
      local matchers = vim.fn['ddu#custom#get_current'](vim.b.ddu_ui_name)['sourceOptions']['_']['matchers']

      local idx = matchers[1] == converter_display_word and 2 or 1
      if matchers[idx] == matcher_substring then
        matchers[idx] = matcher_fzf
        vim.notify('Search mode switched to fuzzy.')
      else
        matchers[idx] = matcher_substring
        vim.notify('Search mode switched to substring.')
      end
      vim.fn['ddu#ui#do_action']('updateOptions', { sourceOptions = { _ = { matchers = matchers } } })
      vim.fn['ddu#ui#do_action']('redraw', { method = 'refreshItems' })
    end, opts)
  end,
})

-- }}}

-- lua_post_source {{{
vim.fn['ddu#custom#patch_global']({
  ui = 'ff',
  uiParams = {
    ff = {
      previewWidth = 80,
      previewSplit = 'vertical',
      startAutoAction = true,
      statusline = false,
      autoAction = { name = 'preview', sync = false },
    },
  },
  sources = { { name = 'file_fd' } },
  sourceParams = {
    file_fd = { args = { '-tf', '-H', '-E', '.git' } },
  },
  sourceOptions = {
    _ = { matchers = { 'matcher_fzf' }, sorters = { 'sorter_fzf' } },
    source = { defaultAction = 'execute' },
    lsp_documentSymbol = { converters = { 'converter_lsp_symbol' } },
    lsp_workspaceSymbol = { converters = { 'converter_lsp_symbol' } },
  },
  filterParams = {
    matcher_fzf = { highlightMatched = 'Search' },
    matcher_substring = { highlightMatched = 'Search' },
  },
  kindOptions = {
    file = { defaultAction = 'open' },
    word = { defaultAction = 'append' },
    action = { defaultAction = 'do' },
    command_history = { defaultAction = 'edit' },
    command = { defaultAction = 'edit' },
    help = { defaultAction = 'open' },
    readme_viewer = { defaultAction = 'open' },
    lsp = { defaultAction = 'open' },
    lsp_codeAction = { defaultAction = 'apply' },
  },
})
-- }}}
