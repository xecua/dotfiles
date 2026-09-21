if vim.g.vscode then
    require("xecua.editors.vscode")
    return
end

vim.cmd("filetype plugin indent off")
vim.cmd("colorscheme sorbet")

pcall(require, "xecua.local-pre") -- ないならないで

require("xecua.opt")
require("xecua.var")
require("xecua.map")
require("xecua.command")
require("xecua.autocmd")
require("xecua.diagnostic")

if vim.g.use_lsp ~= false then
    require("xecua.lsp")
end

if vim.g.neovide ~= nil then
    require("xecua.editors.neovide")
end

vim.cmd("runtime! ftplugin/man.vim")
vim.cmd.packadd("nvim.undotree")

-- plugin
if vim.g.use_plugin ~= false then
    require("xecua.dpp").setup("nvim")
end

pcall(require, "xecua.local")

local has_ui2, ui2 = pcall(require, "vim._core.ui2")
if has_ui2 then
    ui2.enable({
        msg = {
            targets = {
                default = "msg",
                echo = "cmd",
            },
        },
    })
end

vim.cmd("filetype plugin on")
