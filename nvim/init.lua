if vim.g.vscode then
    require("xecua.editors.vscode")
    return
end

vim.cmd("filetype plugin indent off")

pcall(require, "xecua.local-pre") -- ないならないで

require("xecua.opt")
require("xecua.var")
require("xecua.map")
require("xecua.command")
require("xecua.autocmd")
require("xecua.diagnostic")
require("xecua.lsp")

vim.cmd("runtime! ftplugin/man.vim")

if vim.g.neovide ~= nil then
    require("xecua.editors.neovide")
end

-- plugin manager
require("xecua.dpp").setup("nvim")

pcall(require, "xecua.local")

vim.cmd("filetype plugin on")
