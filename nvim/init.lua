if vim.g.vscode then
    require("xecua.editors.vscode")
    return
end

vim.cmd("filetype plugin indent off")

require("xecua.opt")
require("xecua.var")
require("xecua.map")
require("xecua.autocmd")
require("xecua.diagnostic")
require("xecua.lsp")

vim.cmd("runtime! ftplugin/man.vim")

-- :h DiffOrig Luaで書き換えたい
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
