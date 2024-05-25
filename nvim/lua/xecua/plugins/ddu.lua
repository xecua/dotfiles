-- lua_add {{{
vim.g.loaded_ddu_rg = 1 -- prevent command definition by plugin

vim.api.nvim_create_user_command('DduRg', function()
  vim.fn['ddu#start']({
    sources = { { name = 'rg', options = { volatile = true, matchers = {} } } },
    uiParams = { ff = { ignoreEmpty = false } },
  })
end, {})
vim.api.nvim_create_user_command('DduLspDocumentSymbol', function()
  vim.fn['ddu#start']({
    sources = { { name = 'lsp_documentSymbol' } },
    uiParams = { ff = { ignoreEmpty = false, displayTree = true } }
  })
end, {})
vim.api.nvim_create_user_command('DduLspWorkspaceSymbol', function()
  vim.fn['ddu#start']({
    sources = { { name = 'lsp_workspaceSymbol', options = { volatile = true } } },
    uiParams = { ff = { ignoreEmpty = false, displayTree = true } }
  })
end, {})
vim.keymap.set('n', '<Leader>fd', '<Cmd>Ddu file_fd<CR>')
vim.keymap.set('n', '<Leader>fb', '<Cmd>Ddu buffer<CR>')
vim.keymap.set('n', '<Leader>fg', '<Cmd>DduRg<CR>')
vim.keymap.set('n', '<Leader>fls', '<Cmd>DduLspDocumentSymbol<CR>')
vim.keymap.set('n', '<Leader>flw', '<Cmd>DduLspWorkspaceSymbol<CR>')
vim.keymap.set('n', '<C-S-p>', '<Cmd>Ddu command<CR>') -- NOTE: これmacだといけるけど他の環境無理だねえ……

local ddu_group_id = vim.api.nvim_create_augroup('DduMyCnf', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  group = ddu_group_id,
  pattern = 'ddu-ff',
  callback = function()
    local opts = { buffer = true, silent = true }
    vim.keymap.set('n', '<CR>', "<Cmd>call ddu#ui#do_action('itemAction')<CR>", opts)
    vim.keymap.set('n', 'a', "<Cmd>call ddu#ui#do_action('chooseAction')<CR>", opts)
    vim.keymap.set('n', '/', "<Cmd>call ddu#ui#do_action('openFilterWindow')<CR>", opts)
    vim.keymap.set('n', 'p', "<Cmd>call ddu#ui#do_action('preview')<CR>", opts)
    vim.keymap.set('n', ',', "<Cmd>call ddu#ui#do_action('toggleSelectItem')<CR>", opts)
    vim.keymap.set('n', 't', "<Cmd>call ddu#ui#do_action('toggleAllItems')<CR>", opts)
    vim.keymap.set('n', 'f', "<Cmd>call ddu#ui#do_action('itemAction', { 'name': 'quickfix' })<CR>", opts)
    vim.keymap.set('n', 'q', "<Cmd>call ddu#ui#do_action('quit')<CR>", opts)
    vim.keymap.set('n', 'e', "<Cmd>call ddu#ui#do_action('edit')<CR>", opts)
    vim.keymap.set('n', 'w', function()
      -- toggle converter_display_word
      local current = vim.fn['ddu#custom#get_current'](vim.b.ddu_ui_name)
      local converters = current
          and current['sourceOptions']
          and current['sourceOptions']['_']
          and current['sourceOptions']['_']['converters']
          or {}
      if #converters == 0 then
        vim.fn['ddu#ui#do_action'](
          'updateOptions',
          { sourceOptions = { _ = { converters = { 'converter_display_word' } } } }
        )
        require('notify')('Display word included.')
      else
        vim.fn['ddu#ui#do_action']('updateOptions', { sourceOptions = { _ = { converters = {} } } })
        require('notify')('Display word excluded.')
      end
    end, opts)
    vim.keymap.set('n', 's', function()
      -- toggle fuzzy/substring search
      local current = vim.fn['ddu#custom#get_current'](vim.b.ddu_ui_name)
      local options = current and current['sourceOptions'] and current['sourceOptions']['_'] or {}
      local sorters = options['sorters'] or {}
      if #sorters == 0 then
        vim.fn['ddu#ui#do_action']('updateOptions', {
          sourceOptions = {
            _ = { sorters = { 'sorter_fzf' }, matchers = { 'matcher_fzf' } },
          },
        })
        require('notify')('Search mode switched to Fuzzy.')
      else
        vim.fn['ddu#ui#do_action']('updateOptions', {
          sourceOptions = {
            _ = { sorters = {}, matchers = { 'matcher_substring' } },
          },
        })
        require('notify')('Search Mode switched to Substring.')
      end
    end, opts)
  end,
})
vim.api.nvim_create_autocmd('FileType', {
  group = ddu_group_id,
  pattern = 'ddu-ff-filter',
  callback = function()
    local opts = { buffer = true, silent = true }
    vim.keymap.set({ 'n' }, 'q', "<Esc><Cmd>call ddu#ui#do_action('closeFilterWindow')<CR>", opts)
    vim.keymap.set({ 'i', 'n' }, '<CR>', "<Esc><Cmd>call ddu#ui#do_action('closeFilterWindow')<CR>", opts)
  end,
})

-- vim.keymap.set("n", "<C-n>", "<Cmd>DduFiler<CR>")
vim.api.nvim_create_user_command('DduFiler', function()
  vim.fn['ddu#start']({
    ui = 'filer',
    sources = {
      {
        name = 'file',
        params = {},
        options = {
          columns = { 'icon_filename' },
        },
      },
    },
    actionOptions = {
      narrow = { quit = false },
    },
  })
end, {})

vim.api.nvim_create_autocmd('FileType', {
  group = ddu_group_id,
  pattern = 'ddu-filer',
  callback = function()
    local opts = { buffer = true, silent = true }
    local opts_with_desc = function(desc)
      return { buffer = true, silent = true, desc = 'ddu-filer: ' .. desc }
    end

    vim.keymap.set('n', '<CR>', function()
      if vim.fn['ddu#ui#get_item']()['isTree'] == true then
        vim.fn['ddu#ui#do_action']('itemAction', { name = 'narrow' })
      else
        vim.fn['ddu#ui#do_action']('itemAction', { name = 'open' })
      end
    end, opts_with_desc('Narrow(tree), Open(file)'))
    vim.keymap.set('n', '<BS>', function()
      vim.fn['ddu#ui#do_action']('itemAction', { name = 'narrow', params = { path = '..' } })
    end, opts_with_desc('Narrow'))
    vim.keymap.set('n', 'a', "<Cmd>call ddu#ui#do_action('chooseAction')<CR>", opts)
    vim.keymap.set('n', 'q', "<Cmd>call ddu#ui#do_action('quit')<CR>", opts)
    vim.keymap.set('n', 'l', "<Cmd>call ddu#ui#do_action('expandItem')<CR>", opts)
    vim.keymap.set('n', 'h', "<Cmd>call ddu#ui#do_action('collapseItem')<CR>", opts)
    vim.keymap.set('n', 'o', "<Cmd>call ddu#ui#do_action('expandItem', {'mode': 'toggle'})<CR>", opts)
    vim.keymap.set('n', 'n', "<Cmd>call ddu#ui#do_action('newFile')<CR>", opts)
    vim.keymap.set('n', 'r', "<Cmd>call ddu#ui#do_action('rename')<CR>", opts)
    vim.keymap.set('n', 'y', "<Cmd>call ddu#ui#do_action('copy')<CR>", opts)
    vim.keymap.set('n', 'm', "<Cmd>call ddu#ui#do_action('move')<CR>", opts)
    vim.keymap.set('n', 'p', "<Cmd>call ddu#ui#do_action('paste')<CR>", opts)
    vim.keymap.set('n', '<Space>', "<Cmd>call ddu#ui#do_action('toggleSelectItem')<CR>", opts)
    -- toggle hidden files
    vim.keymap.set('n', '!', function()
      local current = vim.fn['ddu#custom#get_current'](vim.b.ddu_ui_name)
      local matchers = current
          and current['sourceOptions']
          and current['sourceOptions']['_']
          and current['sourceOptions']['_']['matchers']
          or {}
      local new_matchers = (#matchers == 0) and { 'matcher_hidden' } or {}
      vim.fn['ddu#ui#do_action']('updateOptions', {
        sourceOptions = {
          _ = {
            matchers = new_matchers,
          },
        },
      })
    end, opts_with_desc('Toggle hidden files'))
  end,
})
-- }}}
-- lua_post_source {{{
vim.fn['ddu#custom#patch_global']({
  ui = 'ff',
  uiOptions = {
    filer = {
      toggle = true,
    },
  },
  uiParams = {
    ff = {
      previewWidth = 80,
      previewSplit = 'vertical',
      filterSplitDirection = 'botright',
      startAutoAction = true,
      autoAction = { name = 'preview', sync = false },
    },
    filer = {
      winWidth = vim.o.columns / 6,
      split = 'vertical',
      splitDirection = 'topleft',
    },
  },
  sources = { { name = 'file_fd' } },
  sourceParams = {
    file_fd = { args = { '-tf', '-H', '-E', '.git' } },
  },
  sourceOptions = {
    _ = { matchers = { 'matcher_fzf' }, sorters = { 'sorter_fzf' } },
    source = { defaultAction = 'execute' },
    rg = { sorters = { 'sorter_alpha' } },
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
    lsp_codeAction = { defaultAction = 'apply' }
  },
})
-- }}}
