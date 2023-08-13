local List = require('plenary.collections.py_list')

vim.g['operator#surround#blocks'] = {
  ['-'] = {
    { block = { '（', '）' }, motionwise = { 'char', 'line', 'block' }, keys = { 'P' } }, -- parenthesis. 全角だと入力しにくいので
    { block = { '「', '」' }, motionwise = { 'char', 'line', 'block' }, keys = { 'B' } }, -- blackets.
    { block = { '『', '』' }, motionwise = { 'char', 'line', 'block' }, keys = { 'D' } }, -- double blackets.
  },
}

vim.api.nvim_create_autocmd('FileType', {
  -- group = init_augroup_id,
  pattern = '*',
  callback = function(args)
    local operator_surround_disabled_buffer_types = List({ 'fern', 'ddu-ff', 'ddu-filer' })
    if not operator_surround_disabled_buffer_types:contains(args.match) then
      vim.keymap.set('n', 'sa', '<Plug>(operator-surround-append)', { buffer = true })
      vim.keymap.set('n', 'sd', '<Plug>(operator-surround-delete)', { buffer = true })
      vim.keymap.set('n', 'sr', '<Plug>(operator-surround-replace)', { buffer = true })
    end
  end,
})
