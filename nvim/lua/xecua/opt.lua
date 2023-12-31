vim.opt.mouse = 'a'
vim.opt.fileformats = { 'unix', 'dos', 'mac' }
vim.opt.termguicolors = true -- t_8f, t_8bは消してみた: 必要なら https://vim-jp.org/vimdoc-ja/term.html#xterm-true-color
vim.opt.fileencodings = { 'ucs-bombs', 'utf-8', 'euc-jp', 'cp932' }
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
vim.opt.updatetime = 300
vim.opt.cmdheight = 1
vim.opt.guifont = { 'UDEV Gothic 35NFLG:h10', 'Cica:h14', 'monospace:h12' }
vim.opt.foldlevelstart = 99 -- open all fold by default
vim.opt.foldcolumn = '1'
vim.opt.switchbuf = { 'useopen', 'split' }
vim.opt.laststatus = 3
vim.opt.formatoptions = 'jonq'
vim.opt.diffopt:append({ 'indent-heuristic', 'algorithm:histogram' })
vim.opt.foldopen:remove({ 'search' })

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
end
