vim.g['ddc_tabnine#storage_dir'] = vim.fn.stdpath('cache') .. '/ddc-tabnine'

vim.fn['ddc#custom#patch_global']('ui', 'pum')

-- copilotがつかえるならそっち
local text_completor = vim.fn['copilot#Call']('checkStatus', vim.empty_dict())['user'] ~= nil and 'copilot' or 'tabnine'

vim.fn['ddc#custom#patch_global']('sources', {
  'nvim-lsp',
  -- "neosnippet",
  'around',
  'file',
  'skkeleton',
  'nvim-obsidian',
  'nvim-obsidian-new',
  text_completor,
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
    neosnippet = {
      mark = 'snip',
      dup = 'keep',
    },
    ['nvim-lsp'] = {
      mark = 'LSP',
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
    tabnine = {
      mark = 'TN',
      isVolatile = true,
    },
    copilot = {
      mark = 'copilot',
      matchers = {},
      isVolatile = true,
    },
    ['nvim-obsidian'] = {
      mark = 'obs'
    },
    ['nvim-obsidian-new'] = {
      mark = 'obs'
    }
  },
  sourceParams = {
    ['nvim-lsp'] = {
      enableResolveItem = true,
      enableAdditionalTextEdit = true,
      confirmBehavior = 'replace',
    },
    ['nvim-obsidian'] = {
      dir = require('xecua.utils').get_local_config().obsidian_dir
    },
    ['nvim-obsidian-new'] = {
      dir = require('xecua.utils').get_local_config().obsidian_dir
    }
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

vim.keymap.set('i', '<Tab>', function()
  if vim.fn['neosnippet#expandable_or_jumpable']() == 1 then
    -- <Plug>にmapするとremapがついて<Tab>に飛ばせなくなるので直接呼んじゃう
    return vim.fn['neosnippet#mappings#expand_or_jump_impl']()
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
  if vim.fn['pum#visible']() then
    return '<Cmd>call pum#map#insert_relative(-1)<CR>'
  else
    return '<C-h>'
  end
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

vim.fn['ddc#enable']()
