local dpp_base_dir = vim.fn.stdpath('cache') .. '/dpp'
local dpp_config_path = vim.fn.stdpath('config') .. '/dpp.ts'
local remote_source_base = 'https://github.com/'
local local_source_base = dpp_base_dir .. '/repos/github.com/'

for _, ext in ipairs({
  'Shougo/dpp.vim',
  'vim-denops/denops.vim',
  'Shougo/dpp-protocol-git',
  'Shougo/dpp-ext-installer',
  'Shougo/dpp-ext-toml',
}) do
  local source_uri = remote_source_base .. ext
  local source_local = local_source_base .. ext
  if vim.fn.isdirectory(source_local) then
    vim.fn.execute('!git clone ' .. source_uri .. ' ' .. source_local)
  end
end

vim.opt.rtp:prepend(local_source_base .. 'Shougo/dpp.vim')
if vim.fn['dpp#min#load_state'](dpp_base_dir) then
  -- something has been changed
  vim.opt.rtp:prepend({
    local_source_base .. 'vim-denops/denops.vim',
    local_source_base .. 'Shougo/dpp-protocol-git',
    local_source_base .. 'Shougo/dpp-ext-installer',
    local_source_base .. 'Shougo/dpp-ext-toml',
  })

  vim.api.nvim_create_autocmd('User', {
    pattern = 'DenopsReady',
    callback = function()
      vim.fn['dpp#make_state'](dpp_base_dir, dpp_config_path)
    end,
  })
end
