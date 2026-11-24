vim.g.firenvim_config = {
    globalSettings = {},
    localSettings = {
        [".*"] = { takeover = "never" },
    },
}
vim.g.use_lsp = false
vim.g.profile = "firenvim"

vim.opt.laststatus = 0
vim.opt.showtabline = 0
vim.opt.number = false
-- 環境(モニタの解像度)依存……
-- vim.opt.guifont = "UDEV Gothic 35NFLG:h14"
