vim.cmd("filetype plugin indent off")

local utils = require("utils")

if vim.g.os == nil then
  if vim.fn.has("win64") == 1 or vim.fn.has("win32") == 1 or vim.fn.has("win16") == 1 then
    vim.g.os = "Windows"
  else
    local uname = vim.fn.system("uname")
    vim.g.os = uname:gsub("\n", "")
    if vim.g.os == "Linux" and string.find(vim.fn.readfile("/proc/version")[1], "microsoft") ~= nil then
      vim.g.os = "WSL"
    end
  end
end

vim.g.config_home = vim.env.XDG_CONFIG_HOME or vim.env.HOME .. "/.config"
vim.g.vim_home = vim.g.config_home .. "/nvim"
vim.g.cache_home = vim.env.XDG_CACHE_HOME or vim.env.HOME .. "/.cache"

vim.opt.mouse = "a"
vim.opt.fileformats = { "unix", "dos", "mac" }
vim.opt.termguicolors = true -- t_8f, t_8bは消してみた: 必要なら https://vim-jp.org/vimdoc-ja/term.html#xterm-true-color
vim.opt.fileencodings = { "ucs-bombs", "utf-8", "euc-jp", "cp932" }
vim.opt.swapfile = false
vim.opt.autoread = true
vim.opt.hidden = true
vim.opt.clipboard = { "unnamedplus", "unnamed" }
vim.opt.number = true
vim.opt.signcolumn = "number"
vim.opt.list = true
vim.opt.listchars = { tab = ">-", trail = "*", nbsp = "+" }
vim.opt.visualbell = true
vim.opt.helplang = { "ja", "en" }
vim.opt.updatetime = 300
vim.opt.cmdheight = 2
vim.opt.laststatus = 3
vim.opt.guifont = { "UDEV Gothic 35NFLG:h12", "Cica:h14", "monospace:h12" }
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()" -- fold block by treesitter
vim.opt.foldlevelstart = 99 -- open all fold by default
vim.opt.foldcolumn = "1"

vim.opt.expandtab = true -- tabstop個の連続したスペースをtabに変換しない
vim.opt.softtabstop = -1 -- <Tab>・<BS>での移動幅(-1 => shiftwidth)
vim.opt.shiftwidth = 0 -- 改行・<</>>でのインデント量(0 => tabstop)
vim.opt.tabstop = 4 -- tab文字の幅
vim.opt.smartindent = true
vim.g.vim_indent_cont = 4 -- 継続行のインデント量を固定

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.wrapscan = true
vim.opt.whichwrap = "b,s,<,>,[,]"
vim.opt.showtabline = 2
vim.opt.showmode = false
vim.opt.undofile = true
vim.opt.undodir = vim.g.cache_home .. "/nvim/undo"

vim.g.vimsyn_embed = "l"
vim.g.tex_flavor = "latex"
vim.g.tex_conceal = ""

-- see :h DiffOrig とりあえず
vim.api.nvim_create_user_command(
  "DiffOrig",
  "vert new | set bt=nofile | r ++edit # | 0d_ | diffthis | wincmd p | diffthis",
  {}
)

-- man.vim
vim.cmd("runtime! ftplugin/man.vim")

-- dein.vim
local dein_dir = vim.g.cache_home .. "/dein"
local dein_repo_dir = dein_dir .. "/repos/github.com/Shougo/dein.vim"

-- vim.o: get option as string (unlike vim.opt:get)-> utilize string.find
if not vim.o.rtp:find("/dein.vim") then
  if vim.fn.isdirectory(dein_repo_dir) then
    -- todo: clone
    vim.fn.execute("!git clone https://github.com/Shougo/dein.vim " .. dein_repo_dir)
  end

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

vim.api.nvim_create_user_command("DeinClean", "call map(dein#check_clean(), { _, val -> delete(val, 'rf') })", {})

-- dependency
local List = require("plenary.collections.py_list")

-- plugin configurations(not yet rewritten)
require("plugin_configs.skkeleton")
require("plugin_configs.ddc")
require("plugin_configs.ddu")
require("plugin_configs.lualine")
require("plugin_configs.quickrun")

-- keymaps
vim.g.mapleader = vim.api.nvim_replace_termcodes("<Space>", true, true, true)
vim.keymap.set("n", "<Esc><Esc>", "<Cmd>nohlsearch<CR>")
vim.keymap.set("n", "<C-[><C-[>", "<Cmd>nohlsearch<CR>")
vim.keymap.set("n", "<Leader>x", "<Cmd>cclose<CR>")
vim.keymap.set("n", "<Leader>t", "<Cmd>TroubleToggle<CR>")
vim.keymap.set("n", "<Leader>u", "<Cmd>UndotreeToggle<CR>")
vim.keymap.set("n", "<C-n>", "<Cmd>Fern . -drawer -toggle<CR>")
-- vim.keymap.set("n", "<C-n>", "<Cmd>DduFiler<CR>")
vim.keymap.set("n", "j", "<Plug>(accelerated_jk_gj)")
vim.keymap.set("n", "k", "<Plug>(accelerated_jk_gk)")
vim.keymap.set("n", "<Leader>j", "<Plug>(jumpcursor-jump)")
vim.keymap.set("n", "sa", "<Plug>(operator-surround-append)")
vim.keymap.set("n", "sd", "<Plug>(operator-surround-delete)")
vim.keymap.set("n", "sr", "<Plug>(operator-surround-replace)")
vim.keymap.set("n", "<Leader>o", "<Cmd>SymbolsOutline<CR>")
vim.keymap.set("n", "<Leader>ar", "<Cmd>CellularAutomaton make_it_rain<CR>")
vim.keymap.set("n", "<Leader>al", "<Cmd>CellularAutomaton game_of_life<CR>")
-- Always enable verymagic (a.k.a. ERE). see :h \v
vim.keymap.set({ "n", "v" }, "/", "/\\v")
vim.keymap.set({ "n", "v" }, "?", "?\\v")
vim.keymap.set({ "n", "v" }, ":s/", ":s/\\v")
vim.keymap.set({ "n", "v" }, ":%s/", ":%s/\\v")

vim.keymap.set("i", "<C-k>", "<Plug>(neosnippet_expand_or_jump)")
vim.keymap.set({ "n", "i", "v" }, "<C-_><C-_>", "<Plug>TComment_<c-_><c-_>")
vim.keymap.set({ "n", "i", "v" }, "<C-_>b", "<Plug>TComment_<c-_>b")

vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]])

-- filetype
vim.filetype.add({
  extension = {
    tsx = "typescriptreact",
    jsx = "typescriptreact",
    er = "python", -- erg
    hx = "haxe",
    frag = "glsl",
    vert = "glsl",
  },
  pattern = {
    [".*/git/config.*"] = { "gitconfig", { priority = 10 } },
    -- [".*/git/ignore.*"] = { "gitignore", { priority = 10 } }, -- cause error?
    ["%.gitconfig.*"] = { "gitconfig", { priority = 10 } },
    [".*/git/attributes.*"] = { "gitattributes", { priority = 10 } },
    [".*/nvim/template/.*"] = { "vim", { priority = 10 } },
    [".textlintrc"] = { "json", { priority = 10 } },
  },
})

-- autocommands
local init_augroup_id = vim.api.nvim_create_augroup("Init", { clear = true }) -- au! will be automatically executed
vim.api.nvim_create_autocmd(
  { "BufWritePre" },
  { group = init_augroup_id, command = [[silent! %s#\($\n\s*\)\+\%$##]], desc = "Remove redundant lines" }
)
vim.api.nvim_create_autocmd({ "VimEnter" }, { group = init_augroup_id, callback = utils.load_local_vimrc })
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  group = init_augroup_id,
  pattern = { "*.tex" },
  callback = function()
    vim.opt_local.makeprg = "latexmk"
  end,
})
vim.api.nvim_create_autocmd({ "FileType" }, {
  group = init_augroup_id,
  callback = function()
    vim.opt_local.tabstop = 2
  end,
  pattern = {
    "c",
    "cpp",
    "fish",
    "html",
    "javascript",
    "typescript",
    "typescriptreact",
    "json",
    "markdown",
    "lua",
    "rst",
    "satysfi",
    "vim",
    "vue",
    "xml",
    "yaml",
  },
})
vim.api.nvim_create_autocmd({ "FileType" }, {
  group = init_augroup_id,
  pattern = { "gitconfig", "go" },
  callback = function()
    vim.opt_local.expandtab = false
  end,
})
vim.api.nvim_create_autocmd({ "FileType" }, {
  group = init_augroup_id,
  pattern = { "neosnippet" },
  callback = function()
    -- neosnippet.vim/ftplugin/neosnippet.vimで上書きしてしまっている
    vim.opt_local.expandtab = false
    vim.opt_local.softtabstop = -1
    vim.opt_local.shiftwidth = 0
    vim.opt_local.tabstop = 2
  end,
})
vim.api.nvim_create_autocmd({ "FileType" }, {
  group = init_augroup_id,
  pattern = { "tex" },
  callback = function()
    vim.fn["lexima#add_rule"]({ char = "(", at = [[\\\%#]], input_after = [=['\)]=] })
    vim.fn["lexima#add_rule"]({ char = "[", at = [[\\\%#]], input_after = [=[\]]=] })
    vim.fn["lexima#add_rule"]({ char = "`", at = [[`\%#]], input_after = [['''']] })
    vim.fn["lexima#add_rule"]({ char = "`", at = [[`\%#`]], input = [[<Right>''''<Left><Left>]] })
  end,
})
vim.api.nvim_create_autocmd(
  { "BufWritePre", "FileWritePre" },
  { group = init_augroup_id, pattern = { "*.saty", "*.tex" }, callback = utils.normalize_punctuation }
)
vim.api.nvim_create_autocmd(
  { "BufWritePost", "FileWritePost" },
  { group = init_augroup_id, pattern = { "*.saty", "*.tex" }, command = "QuickRun" }
)

if vim.fn.executable("pdftotext") then
  vim.api.nvim_create_autocmd({ "BufRead" }, {
    group = init_augroup_id,
    pattern = { "*.pdf" },
    command = [[enew | file #.txt | 0read !pdftotext -layout -nopgbrk "#" -]],
  })
end

-- plugin configuration by variable
vim.g["neosnippet#snippets_directory"] = vim.g.vim_home .. "/mysnippets"
vim.g.tcomment_maps = false

vim.g["operator#surround#blocks"] = {
  ["-"] = {
    { block = { "（", "）" }, motionwise = { "char", "line", "block" }, keys = { "P" } }, -- 全角だと入力しにくいのでP、か
    { block = { "「", "」" }, motionwise = { "char", "line", "block" }, keys = { "B" } },
    { block = { "『", "』" }, motionwise = { "char", "line", "block" }, keys = { "D" } },
  },
}

vim.g.startify_change_to_vcs_root = 1
vim.g.startify_lists = {
  { type = "files", header = { "   MRU" } },
  { type = "bookmarks", header = { "   Bookmarks" } },
  { type = "sessions", header = { "   Sessions" } },
}
vim.g.startify_bookmarks = {
  "~",
  "~/.config/nvim",
}

-- conditional configurations

if vim.g.os == "Darwin" then
  vim.g.python3_host_prog = "/usr/local/bin/python3"
elseif vim.g.os == "Linux" then
  vim.g.python3_host_prog = "/usr/bin/python"
end

-- fzf.vim (when fzf was installed with Homebrew)
if vim.fn.isdirectory("/usr/local/opt/fzf") == 1 then
  vim.opt.rtp:append("/usr/local/opt/fzf")
end

if vim.g.neovide ~= nil then
  -- 通常のターミナルでやろうとするとめんどくさい(失敗するとバッファ上に表示されて鬱陶しい)
  vim.opt.title = true
end

if vim.g.vscode ~= nil then
  vim.g.startify_disable_at_vimenter = 1
  vim.g.vim_backslash_disable_default_mapping = 1
  -- WSL: Win側で探してしまい見つからない
  vim.g["denops#deno"] = vim.fn.executable("deno") == 1 and "deno" or vim.env.HOME .. "/.deno/bin/deno"

  vim.cmd("filetype plugin on")
else
  -- vim.opt.ambiwidth = "double" -- そもそもなんでこれ入れてたんだっけ

  -- lsp config
  -- setting up mason.nvim
  require("plugin_configs.mason.satysfi-ls")
  local index = require("mason-registry.index")
  index["satysfi-ls"] = "plugin_configs.mason.satysfi-ls"

  require("mason").setup()
  require("plugin_configs.lspconfig")
  require("plugin_configs.null-ls")
  require("plugin_configs.dap")

  -- outline
  require("symbols-outline").setup()

  -- treesitter config
  require("nvim-treesitter.configs").setup({
    highlight = {
      enable = true,
    },
    auto_install = true,
  })

  -- Diagnostics
  require("trouble").setup({})

  -- Cursor highlight
  require("illuminate").configure({
    filetype_overrides = {
      toml = { providers = { "regex" } },
    },
  })

  vim.cmd("colorscheme molokai")

  vim.g.loaded_matchparen = 1 -- disable default settings
  local closetag_xhtml_filetypes = List({ "xhtml", "jsx", "tsx", "typescriptreact" })
  local closetag_normal_filetypes = List({ "html", "phtml", "xml" })
  vim.g.closetag_xhtml_filetypes = closetag_xhtml_filetypes:join(",")
  vim.g.closetag_filetypes = closetag_xhtml_filetypes:concat(closetag_normal_filetypes):join(",")

  vim.g["fern#renderer"] = "nerdfont"

  vim.fn["tcomment#type#Define"]("satysfi", "%% %s")
  vim.fn["tcomment#type#Define"]("glsl", "// %s")
  vim.fn["tcomment#type#Define"]("kotlin", "// %s")
  vim.fn["tcomment#type#Define"]("tex_block", [[\begin{comment}%s\end{comment}]])

  vim.fn["popup_preview#enable"]()
  vim.fn["signature_help#enable"]()

  vim.cmd("filetype plugin indent on")
end
