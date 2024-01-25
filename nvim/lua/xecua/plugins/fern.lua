-- lua_add {{{
vim.g['fern#renderer'] = 'nerdfont'

vim.keymap.set('n', '<C-n>', '<Cmd>Fern . -reveal=%:p -drawer -toggle<CR>')

vim.api.nvim_create_autocmd('FileType', {
  -- group = init_augroup_id,
  pattern = { 'fern' },
  callback = function()
    vim.opt_local.list = false
    vim.opt_local.wrap = false

    vim.keymap.set('n', '<LeftRelease>', function()
      return vim.fn['fern#smart#leaf'](
        '<Plug>(fern-action-open)',
        '<Plug>(fern-action-expand)',
        '<Plug>(fern-action-collapse)'
      )
    end, { buffer = true, expr = true }) -- 選択は<LeftMouse>でやってる
    vim.keymap.set('n', 'e', '<Plug>(fern-action-open:select)', { buffer = true })
    vim.keymap.set('n', 's', '<Plug>(fern-action-open:split)', { buffer = true })
    vim.keymap.set('n', 'v', '<Plug>(fern-action-open:vsplit)', { buffer = true })
  end,
})
-- }}}
