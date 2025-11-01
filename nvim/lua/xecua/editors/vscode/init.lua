local vscode = require("vscode")
vim.notify = vscode.notify

vim.g.clipboard = vim.g.vscode_clipboard

vim.g.mapleader = vim.api.nvim_replace_termcodes("<Space>", true, true, true)

vim.opt.cmdheight = 500 -- workaround
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.wrapscan = true
vim.opt.whichwrap = "b,s,<,>,[,]"
vim.opt.showmode = true
vim.opt.clipboard = { "unnamedplus", "unnamed" }

require("xecua.editors.vscode.map")
require("xecua.plugins.dpp").setup("vscode")
