if vim.g.vscode then
    require("xecua.editors.vscode")
    return
end

vim.cmd("filetype plugin indent off")

require("xecua.opt")
require("xecua.var")
require("xecua.map")
require("xecua.autocmd")
require("xecua.lsp")

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

vim.diagnostic.config({
    virtual_lines = {
        format = function(diag)
            local s = string.format("%s: %s", diag.source, diag.message)
            if diag.code then
                s = string.format("%s [%s]", s, diag.code)
            end
            return s
        end,
    },
    signs = false,
})

if vim.g.neovide ~= nil then
    require("xecua.editors.neovide")
end

-- plugin manager
require("xecua.plugins.dpp")

pcall(require, "xecua.local") -- ないならないで

vim.cmd("filetype plugin on")
