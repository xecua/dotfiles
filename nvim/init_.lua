vim.cmd("filetype plugin indent off")

local utils = require("utils")
local List = require('plenary.collections.py_list')

if vim.g.os == nil then
  if vim.fn.has("win64") == 1 or vim.fn.has("win32") == 1 or vim.fn.has("win16") then
    vim.g.os = "Windows"
  else
    local uname = vim.fn.system("uname")
    vim.g.os = uname:gsub("\n", "")
    if vim.g.os == "Linux" and vim.fn.readfile("/proc/version")[0].find("microsoft") ~= nil then
      vim.g.os = "WSL"
    end
  end
end

vim.g.config_home = vim.env.XDG_CONFIG_HOME or vim.env.HOME .. "/.config"
vim.g.vim_home = vim.g.config_home .. "/nvim"
vim.g.cache_Home = vim.env.XDG_CACHE_HOME or vim.env.HOME .. "/.cache"

vim.opt.mouse = "a"
vim.opt.title = true
vim.opt.fileformats = { "unix", "dos", "mac" }
vim.opt.termguicolors = true -- t_8f, t_8bは消してみた: 必要なら https://vim-jp.org/vimdoc-ja/term.html#xterm-true-color
vim.opt.fileencodings = { "ucs-bombs", "utf-8", "euc-jp", "cp932" }
vim.opt.swapfile = false
vim.opt.autoread = true
vim.opt.hidden = true
vim.opt.clipboard:append("unnamedplus")
vim.opt.number = true
vim.opt.list = true
vim.opt.listchars = { tab = ">-", trail = "*", nbsp = "+" }
vim.opt.visualbell = true
vim.opt.helplang = { "ja", "en" }
vim.opt.updatetime = 300

vim.opt.expandtab = true -- tabstop個の連続したスペースをtabに変換しない
vim.opt.softtabstop = -1 -- <Tab>・<BS>での移動幅(-1 => shiftwidth)
vim.opt.shiftwidth = 0 -- 改行・<</>>でのインデント量(0 => tabstop)
vim.opt.tabstop = 4 -- tab文字の幅
vim.opt.smartindent = true
vim.g.vim_indent_cont = 4 -- 継続行のインデント量を固定

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.wrapscan = true
vim.opt.whichwrap = { "b", "s", "<", ">", "[", "]" }
vim.opt.showtabline = 2
vim.opt.noshowmode = true
vim.opt.undofile = true
vim.opt.undodir = vim.g.cache_home .. "/nvim/undo"

vim.g.vimsyn_embed = "l"
vim.g.tex_flavor = "latex"
vim.g.tex_conceal = ""


-- see :h DiffOrig とりあえず
vim.cmd('command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis | wincmd p | diffthis')

-- dein.vim
local dein_dir = vim.g.cache_home .. "/dein"
local dein_repo_dir = dein_dir .. "/repos/github.com/Shougo/dein.vim"

-- runtimepath
if false then
  vim.opt.rtp:prepend(dein_repo_dir)
end

if vim.fn["dein#load_state"](dein_dir) == 1 then
  vim.fn["dein#begin"](dein_dir)

  vim.fn["dein#load_toml"](vim.g.vim_home .. "/dein.toml", { lazy = 0 })
  vim.fn["dein#load_toml"](vim.g.vim_home .. "/dein_lazy.toml", { lazy = 1 })

  vim.fn["dein#end"]()
  vim.fn["dein#save_state"]()
end

if vim.fn["dein#check_install"]() == 1 then
  vim.fn["dein#install"]()
end

-- plugin configurations(not yet rewritten)
vim.cmd('runtime! conf/*.vim')

-- keymaps
vim.g.mapleader = vim.api.nvim_replace_termcodes('<Space>', true, true, true)
vim.keymap.set("n", "<Esc><Esc>", "<Cmd>nohlsearch<CR>")
vim.keymap.set("n", "<Leader>x", "<Cmd>cclose<CR>")
vim.keymap.set("n", "<Leader>u", "<Cmd>UndotreeToggle<CR>")
vim.keymap.set("n", "j", "<Plug>(accelerated_jk_gj)")
vim.keymap.set("n", "k", "<Plug>(accelerated_jk_gk)")
vim.keymap.set("n", "<Leader>j", "<Plug>(jumpcursor-jump)")
-- Resize without repeately pressing C-w: https://zenn.dev/mattn/articles/83c2d4c7645faa
vim.keymap.set('n', '<C-w>+', '<C-w>+<SID>ws')
vim.keymap.set('n', '<C-w>-', '<C-w>-<SID>ws')
vim.keymap.set('n', '<C-w>>', '<C-w>><SID>ws')
vim.keymap.set('n', '<C-w><', '<C-w><<SID>ws')
vim.keymap.set('n', '<SID>ws+', '<C-w>+<SID>ws', {script = true})
vim.keymap.set('n', '<SID>ws-', '<C-w>-<SID>ws', {script = true})
vim.keymap.set('n', '<SID>ws>', '<C-w>><SID>ws', {script = true})
vim.keymap.set('n', '<SID>ws<', '<C-w><<SID>ws', {script = true})
vim.keymap.set('n', '<SID>ws', '')

vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]])

-- autocommands
local init_augroup_id = vim.api.create_augroup('Init') -- au! will be automatically executed
vim.api.create_autocmd({'BufWritePre'}, { group = init_augroup_id, command = [[silent! %s#\($\n\s*\)\+\%$##]], desc = 'Remove redundant lines' })
vim.api.create_autocmd({'VimEnter'}, { group = init_augroup_id, callback = utils.load_local_vimrc })
vim.api.create_autocmd({'BufNewFile', 'BufRead'}, { group = init_augroup_id, pattern = {'*.tsx', '*.jsx'},
  callback = function() vim.opt_local.filetype = 'typescriptreact' end
})
vim.api.create_autocmd({'BufNewFile', 'BufRead'}, { group = init_augroup_id, pattern = {'*.tex'},  callback = function() vim.opt_local.makeprg = 'latexmk' end })
vim.api.create_autocmd({'FileType'},  { group = init_augroup_id , callback = function() vim.opt_local.tabstop = 2 end,
  pattern = {'c', 'cpp', 'fish', 'html', 'javascript', 'typescript', 'typescriptreact', 'json', 'lua', 'rst', 'satysfi', 'vim', 'vue', 'xml', 'yaml'}
})
vim.api.create_autocmd({'FileType'}, { group = init_augroup_id, pattern = {'gitconfig', 'go'}, callback = function() vim.opt_local.expandtab = false end })
vim.api.create_autocmd({'FileType'}, { group = init_augroup_id, pattern = {'neosnippet'}, callback = function()
  -- neosnippet.vim/ftplugin/neosnippet.vimで上書きしてしまっている
  vim.opt_local.expandtab = false
  vim.opt_local.softtabstop = -1
  vim.opt_local.shiftwidth = 0
  vim.opt_local.tabstop = 2
end})
vim.api.create_autocmd({'FileType'}, { group = init_augroup_id , pattern = {'tex'}, callback = function()
  vim.fn['lexima#add_rule']({char= '(', at= [[\\\%#]], input_after= [=['\)]=]})
  vim.fn['lexima#add_rule']({char= '[', at=[[\\\%#]], input_after= [=[\]]=]})
  vim.fn['lexima#add_rule']({char= '`', at= [[`\%#]], input_after= [['''']]})
  vim.fn['lexima#add_rule']({char= '`', at= [[`\%#`]], input =  [[<right>''''<left><left>]]})
end})
vim.api.create_autocmd({'BufWritePre', 'FileWritePre'}, { group = init_augroup_id,pattern = {'*.md', '*.saty', '*.tex'}, callback = utils.normalize_punctuation })
vim.api.create_autocmd({'BufWritePost', 'FileWritePost'}, { group = init_augroup_id, pattern = {'*.saty', '*.tex'}, command = 'QuickRun' })

if vim.fn.executable('pdftotext') then
  vim.api.create_autocmd({'BufRead'}, { group = init_augroup_id, pattern = {'*.pdf'}, command = [[enew | file #.txt | 0read !pdftotext -layout -nopgbrk "#" -]] })
end


-- conditional configurations

if vim.g.neovide ~= nil then
  vim.opt.guifont = "Cica:h12"
end

if vim.g.os == "Darwin" then
  vim.g.python3_host_prog = "/usr/local/bin/python3"
elseif vim.g.os == "Linux" then
  vim.g.python3_host_prog = "/usr/bin/python"
end

if vim.g.vscode ~= nil then
  vim.g.startify_disable_at_vimenter = 1
  vim.g.vim_backslash_disable_default_mapping = 1

  vim.cmd("filetype plugin on")
else
  vim.opt.ambiwidth = "double"

  -- init.luaの時点で0.5は仮定してるのでチェックはパス
  vim.env.WORKSPACE = vim.env.HOME .. "/Documents/eclipse-workspace/jdt.ls" -- jdt.ls workspace
  -- lsp config
  require("lsp")

  -- treesitter config
  require('nvim-treesitter.configs').setup({
    highlight = { enable = true }
  })

  vim.cmd("colorscheme molokai")

  vim.g.loaded_matchparen = 1 -- disable default settings
  local closetag_xhtml_filetypes = List({"xhtml", "jsx", "tsx", "typescriptreact"})
  local closetag_normal_filetypes = List({"html", "phtml", "xml"})
  vim.g.closetag_xhtml_filetypes = closetag_xhtml_filetypes:join(',')
  vim.g.closetag_filetypes = closetag_xhtml_filetypes:concat(closetag_xhtml_filetypes, closetag_normal_filetypes):join(",")

  vim.fn['tcomment#type#Define']('satysfi', '%% %s')
  vim.fn['tcomment#type#Define']('glsl', '// %s')

  vim.fn['popup_preview#enable']()
  vim.fn['signature_help#enable']()

  vim.cmd('filetype plugin indent on')
end