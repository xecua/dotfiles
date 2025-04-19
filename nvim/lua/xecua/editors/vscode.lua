local vscode = require("vscode")
vim.notify = vscode.notify
vim.g.clipboard = vim.g.vscode_clipboard

vim.g.mapleader = vim.api.nvim_replace_termcodes("<Space>", true, true, true)

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.wrapscan = true
vim.opt.whichwrap = "b,s,<,>,[,]"
vim.opt.showmode = true
vim.opt.clipboard = { "unnamedplus", "unnamed" }

vim.keymap.set("n", "<C-n>", function()
    vscode.action("workbench.action.toggleSidebarVisibility")
    -- vscode.action("workbench.explorer.fileView.toggleVisibility") -- ← 動かない? (放置されたissueあり)
end)
vim.keymap.set("n", "<C-_><C-_>", function()
    vscode.action("editor.action.commentLine")
end)
vim.keymap.set("v", "<C-_>", function()
    vscode.action("editor.action.blockComment")
end)
vim.keymap.set("n", "<Leader>fd", function()
    vscode.action("workbench.action.quickOpen")
end)
vim.keymap.set("n", "<Leader>fg", function()
    vscode.action("workbench.action.terminal.searchWorkspace")
end)
