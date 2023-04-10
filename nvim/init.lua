vim.cmd("filetype plugin indent off")

local utils = require("utils")

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
vim.opt.guifont = { "UDEV Gothic 35NFLG:h12", "Cica:h14", "monospace:h12" }
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()" -- fold block by treesitter
vim.opt.foldlevelstart = 99 -- open all fold by default
vim.opt.foldcolumn = "1"
vim.opt.switchbuf = { "useopen", "split" }

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
vim.opt.undodir = vim.fn.stdpath("cache") .. "/undo"

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

-- plugin managers
require("plugin_configs.dein")
-- require("plugin_configs.jetpack")

-- dependency
local List = require("plenary.collections.py_list")

-- plugin configurations
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
vim.keymap.set({ "n", "v" }, "<Leader>b", "<Plug>(openbrowser-open)")
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
local init_augroup_id = vim.api.nvim_create_augroup("Init", { clear = true })
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

-- Switching automatic punctuation substitution
local punct_sub_augroup_id = vim.api.nvim_create_augroup("PunctSub", { clear = true })
vim.api.nvim_create_user_command("PunctSubEnable", function()
  vim.api.nvim_create_autocmd({ "BufWritePre", "FileWritePre" }, {
    group = punct_sub_augroup_id,
    buffer = 0, -- current buffer (like other apis; not documented, though)
    callback = utils.normalize_punctuation,
  })
end, {})
vim.api.nvim_create_user_command("PunctSubDisable", function()
  for _, autocmd in
    pairs(vim.api.nvim_get_autocmds({
      group = punct_sub_augroup_id,
      buffer = 0,
    }))
  do
    vim.api.nvim_del_autocmd(autocmd.id)
  end
end, {})
-- LaTeX and SATySFi: enabled by default (it is intentional that the augroup is Init)
vim.api.nvim_create_autocmd(
  { "BufWritePre", "FileWritePre" },
  { group = init_augroup_id, pattern = { "*.saty", "*.tex" }, command = "PunctSubEnable" }
)

-- plugin configuration by variable
vim.g["neosnippet#snippets_directory"] = vim.fn.stdpath("config") .. "/mysnippets"
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

  -- tabnine
  require("tabnine").setup({
    accept_keymap = "<C-k>",
  })

  -- outline
  require("symbols-outline").setup()

  -- treesitter config
  local treesitter_parsers_dir = vim.fn.stdpath("cache") .. "/parsers"
  require("nvim-treesitter.configs").setup({
    parser_install_dir = treesitter_parsers_dir,
    highlight = {
      enable = true,
    },
    auto_install = true,
    ignore_install = {
      "fish", -- seems to have some problem https://github.com/ram02z/tree-sitter-fish/issues/17
    },
  })
  vim.opt.rtp:append(treesitter_parsers_dir)

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
  local closetag_xhtml_filetypes = List({ "xhtml", "jsx", "tsx", "typescriptreact", "astro" })
  local closetag_normal_filetypes = List({ "html", "phtml", "xml" })
  vim.g.closetag_xhtml_filetypes = closetag_xhtml_filetypes:join(",")
  vim.g.closetag_filetypes = closetag_xhtml_filetypes:concat(closetag_normal_filetypes):join(",")

  vim.g["fern#renderer"] = "nerdfont"

  vim.fn["tcomment#type#Define"]("satysfi", "%% %s")
  vim.fn["tcomment#type#Define"]("glsl", "// %s")
  vim.fn["tcomment#type#Define"]("kotlin", "// %s")
  vim.fn["tcomment#type#Define"]("hjson", "# %s")
  vim.fn["tcomment#type#Define"]("hjson_block", "/* %s */")
  vim.fn["tcomment#type#Define"]("tex_block", [[\begin{comment}%s\end{comment}]])

  vim.fn["popup_preview#enable"]()
  vim.fn["signature_help#enable"]()
end

vim.cmd("filetype plugin on")
