if vim.g.vscode then
    require("xecua.editors.vscode")
    return
end

vim.cmd("filetype plugin indent off")
vim.cmd("colorscheme sorbet")

vim.loader.enable()

pcall(require, "xecua.local-pre") -- ないならないで

require("xecua.opt")
require("xecua.var")
require("xecua.map")
require("xecua.command")
require("xecua.autocmd")
require("xecua.diagnostic")

vim.cmd("runtime! ftplugin/man.vim")
vim.cmd.packadd("nvim.undotree")

if vim.g.started_by_firenvim then
    require("xecua.editors.firenvim")
elseif vim.g.neovide ~= nil then
    require("xecua.editors.neovide")
end

if vim.g.use_lsp ~= false then
    require("xecua.lsp")
end

-- plugin
if vim.g.use_plugin ~= false then
    require("xecua.goda-pm").setup(vim.g.profile or "nvim")
end

pcall(require, "xecua.local")

if vim.fn.has("nvim-0.13") then
    require("vim._core.ui2").enable({
        msg = {
            targets = {
                default = "msg",
                echo = "cmd",
            },
        },
    })
end

vim.cmd("filetype plugin on")
