vim.cmd('filetype plugin indent off')

require('xecua.opt')
require('xecua.var')
require('xecua.map')
require('xecua.autocmd')

vim.cmd('runtime! ftplugin/man.vim')
-- fzf.vim (when fzf was installed with Homebrew)
if vim.fn.isdirectory('/usr/local/opt/fzf') == 1 then
  vim.opt.rtp:append('/usr/local/opt/fzf')
end

-- filetype
vim.filetype.add({
  extension = {
    tsx = 'typescriptreact',
    jsx = 'typescriptreact',
    er = 'python', -- erg
    hx = 'haxe',
    frag = 'glsl',
    vert = 'glsl',
  },
  pattern = {
    ['.*/git/config.*'] = { 'gitconfig', { priority = 10 } },
    -- [".*/git/ignore.*"] = { "gitignore", { priority = 10 } }, -- cause error?
    ['%.gitconfig.*'] = { 'gitconfig', { priority = 10 } },
    ['.*/git/attributes.*'] = { 'gitattributes', { priority = 10 } },
    ['.*/nvim/template/.*'] = { 'vim', { priority = 10 } },
    ['.textlintrc'] = { 'json', { priority = 10 } },
  },
})

-- :h DiffOrig Luaで書き換える?
vim.api.nvim_create_user_command(
  'DiffOrig',
  'vert new | set bt=nofile | r ++edit # | 0d_ | diffthis | wincmd p | diffthis',
  {}
)

if vim.g.neovide ~= nil then
  vim.api.nvim_create_user_command('NeovideToggleFullscreen', function()
    vim.g.neovide_fullscreen = not vim.g.neovide_fullscreen
  end, {})
end

-- plugin manager
require('xecua.plugins.dein')
-- plugin configurations

-- obsidian
if require('xecua.utils').get_local_config().obsidian_dir ~= nil then
  require('obsidian').setup({
    dir = require('xecua.utils').get_local_config().obsidian_dir,
    daily_notes = {
      folder = 'DairyNote',
      date_format = '%Y-%m-%d',
    },
    disable_frontmatter = true,
  })
end

vim.cmd('colorscheme molokai')
vim.cmd('filetype plugin on')
