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
require("xecua.lsp")

vim.cmd("runtime! ftplugin/man.vim")

if vim.g.neovide ~= nil then
    require("xecua.editors.neovide")
end

-- plugin manager
require("xecua.dpp").setup("nvim")

pcall(require, "xecua.local")

local has_ui2, ui2 = pcall(require, "vim._core.ui2")
if has_ui2 then
    ui2.enable({
        msg = {
            target = "msg",
            -- targets = {} -- <- |ui-messages|のkey -> "cmd"/"msg"/"pager"。dialogは使えない
        },
        cmd = {
            target = "msg",
        },
    })
end

vim.cmd("filetype plugin on")
