vim.opt.mouse = 'a'
vim.opt.fileformats = { 'unix', 'dos', 'mac' }
vim.opt.fileencodings = { 'ucs-bom', 'utf-8', 'euc-jp', 'cp932', 'sjis', 'euc-jis-2004', 'iso-2022-jp' }
vim.opt.swapfile = false
vim.opt.autoread = true
vim.opt.hidden = true
vim.opt.clipboard = { 'unnamedplus', 'unnamed' }
vim.opt.number = true
vim.opt.signcolumn = 'number'
vim.opt.list = true
vim.opt.listchars = { tab = '>-', lead = '･', multispace = '･', trail = '･', nbsp = '+' }
vim.opt.visualbell = true
vim.opt.helplang = { 'ja', 'en' }
vim.opt.cmdheight = 1
vim.opt.foldlevelstart = 99 -- open all fold by default
vim.opt.foldcolumn = '1'
vim.opt.switchbuf = { 'useopen', 'split' }
vim.opt.laststatus = 3
vim.opt.formatoptions = 'jonqr'
vim.opt.diffopt:append({ 'indent-heuristic', 'algorithm:histogram' })
vim.opt.foldopen:remove({ 'search' })
vim.opt.scrolloff = 2
vim.opt.sidescrolloff = 2
vim.opt.title = true

vim.opt.expandtab = true -- tabstop個の連続したスペースをtabに変換しない
vim.opt.softtabstop = -1 -- <Tab>・<BS>での移動幅(-1 => shiftwidth)
vim.opt.shiftwidth = 0 -- 改行・<</>>でのインデント量(0 => tabstop)
vim.opt.tabstop = 4 -- tab文字の幅
vim.opt.smartindent = true
vim.g.vim_indent_cont = 4 -- 継続行のインデント量を固定

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.wrapscan = true
vim.opt.whichwrap = 'b,s,<,>,[,]'
vim.opt.showtabline = 2
vim.opt.showmode = false
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath('cache') .. '/undo'

if vim.g.neovide ~= nil then
  -- 通常のターミナルでやろうとするとめんどくさい(失敗するとバッファ上に表示されて鬱陶しい)
  vim.opt.title = true
  vim.env.COLORTERM = 'truecolor'
  -- vim.g.neovide_transparency = 0.5

  -- Neovide: オプションは最後にくっついて全部のフォントに適用される あと'monospace'は解決してくれない
  vim.opt.guifont = 'UDEV Gothic 35NFLG:h8'
end
