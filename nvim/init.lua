vim.cmd("filetype plugin indent off")

require("xecua.opt")
require("xecua.var")
require("xecua.map")
require("xecua.autocmd")

vim.cmd("runtime! ftplugin/man.vim")
-- fzf.vim (when fzf was installed with Homebrew)
if vim.fn.isdirectory("/opt/homebrew/opt/fzf") == 1 then
    vim.opt.rtp:append("/opt/homebrew/opt/fzf")
end

-- :h DiffOrig Luaで書き換える?
vim.api.nvim_create_user_command(
    "DiffOrig",
    "vert new | set bt=nofile | r ++edit # | 0d_ | diffthis | wincmd p | diffthis",
    {}
)

if vim.g.neovide ~= nil then
    require("xecua.editors.neovide")
end

-- plugin manager
require("xecua.plugins.dpp")

pcall(require, "xecua.local") -- ないならないで

vim.cmd("filetype plugin on")
