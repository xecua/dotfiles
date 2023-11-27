local dpp_base_dir = vim.fn.stdpath('cache') .. '/dpp'
local dpp_config_path = vim.fn.stdpath('config') .. '/typescript/dpp.ts'

local function check_install(plugin_name)
  local source_remote = string.format('https://github.com/%s', plugin_name)
  local source_local = string.format('%s/repos/github.com/%s', dpp_base_dir, plugin_name)
  if vim.fn.isdirectory(source_local) == 0 then
    vim.print('installing ' .. plugin_name .. '...')
    vim.fn.execute(string.format('!git clone %s %s', source_remote, source_local))
  end
  vim.opt.rtp:prepend(source_local)
end

for _, ext in ipairs({
  'Shougo/dpp.vim',
  'Shougo/dpp-protocol-git',
  'Shougo/dpp-ext-installer',
  'Shougo/dpp-ext-toml',
  'Shougo/dpp-ext-lazy',
}) do
  check_install(ext)
end

local dpp = require('dpp')

if dpp.load_state(dpp_base_dir) == 1 then
  check_install('vim-denops/denops.vim')

  vim.api.nvim_create_autocmd('User', {
    pattern = 'DenopsReady',
    callback = function()
      dpp.make_state(dpp_base_dir, dpp_config_path)
    end,
  })
end

vim.api.nvim_create_user_command('DppInstall', "call dpp#async_ext_action('installer', 'install')", {})
vim.api.nvim_create_user_command('DppUpdate', "call dpp#async_ext_action('installer', 'update')", {})

vim.api.nvim_create_autocmd('VimEnter', {
  pattern = '*',
  command = "call dpp#util#_call_hook('post_source')",
})
