local dpp_base_dir = vim.fn.stdpath('cache') .. '/dpp'
local dpp_config_path = vim.fn.stdpath('config') .. '/typescript/dpp.ts'

local function add_plugin(plugin_name)
  local source_local = string.format('%s/repos/github.com/%s', dpp_base_dir, plugin_name)
  if vim.fn.isdirectory(source_local) == 0 then
    vim.notify('installing ' .. plugin_name .. '...')
    local source_remote = string.format('https://github.com/%s', plugin_name)
    vim.fn.execute(string.format('!git clone %s %s', source_remote, source_local))
  end
  vim.opt.rtp:prepend(source_local)
end

vim.api.nvim_create_user_command('DppInstall', "call dpp#async_ext_action('installer', 'install')", {})
vim.api.nvim_create_user_command('DppUpdate', "call dpp#async_ext_action('installer', 'update')", {})

vim.api.nvim_create_autocmd('User', {
  pattern = 'Dpp:makeStatePost',
  callback = function()
    -- load_stateすればいい感じになるっぽいんだよなあ ただし毎回するとまあまあめんどい
    vim.notify('make_state finished. please restart neovim.')
  end,
})
vim.api.nvim_create_autocmd('BufWritePost', {
  pattern = { '*.lua', '*.toml', '*.ts', '*.vim' },
  command = 'call dpp#check_files()',
})

add_plugin('Shougo/dpp.vim')
if require('dpp').load_state(dpp_base_dir) == 1 then
  for _, ext in ipairs({
    'Shougo/dpp-protocol-git',
    'Shougo/dpp-ext-installer',
    'Shougo/dpp-ext-toml',
    'Shougo/dpp-ext-lazy',
    'vim-denops/denops.vim',
  }) do
    add_plugin(ext)
  end

  vim.fn['denops#server#wait_async'](function()
    -- denopsが立ち上がったらmake_stateする
    require('dpp').make_state(dpp_base_dir, dpp_config_path)
  end)
end

if vim.v.vim_did_enter == 1 then
  vim.fn['dpp#util#_call_hook']('post_source')
else
  vim.api.nvim_create_autocmd('VimEnter', {
    pattern = '*',
    command = 'call dpp#util#_call_hook("post_source")',
  })
end
