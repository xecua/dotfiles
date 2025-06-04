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

vim.keymap.set({ "n", "x" }, "<C-w><C-h>", function()
    vscode.action("workbench.action.navigateLeft")
end)
vim.keymap.set({ "n", "x" }, "<C-w><C-j>", function()
    vscode.action("workbench.action.navigateDown")
end)
vim.keymap.set({ "n", "x" }, "<C-w><C-k>", function()
    vscode.action("workbench.action.navigateUp")
end)
vim.keymap.set({ "n", "x" }, "<C-w><C-l>", function()
    vscode.action("workbench.action.navigateRight")
end)

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
vim.keymap.set("n", "<Leader>fb", function()
    vscode.action("workbench.files.action.focusOpenEditorsView")
end)
vim.keymap.set("n", "<Leader>fg", function()
    vscode.action("workbench.action.terminal.searchWorkspace")
end)

vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
vim.keymap.set("n", "<Leader>lh", vim.lsp.buf.signature_help, {})
vim.keymap.set("n", "<Leader>lr", vim.lsp.buf.references, {})
vim.keymap.set("n", "<Leader>ld", vim.lsp.buf.definition, {})
vim.keymap.set("n", "<Leader>lt", vim.lsp.buf.type_definition, {})
vim.keymap.set("n", "<Leader>li", vim.lsp.buf.implementation, {})
vim.keymap.set("n", "<Leader>la", vim.lsp.buf.code_action, {})
vim.keymap.set("n", "<Leader>lci", vim.lsp.buf.incoming_calls, {})
vim.keymap.set("n", "<Leader>lco", vim.lsp.buf.outgoing_calls, {})

vim.keymap.set("n", "<Leader>db", function()
    vscode.action("editor.debug.action.toggleBreakpoint")
end)

-- accelerated-jkとか入れる?
