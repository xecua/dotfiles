-- bootstrap
local jetpackfile = vim.fn.stdpath("data") .. "/site/pack/jetpack/opt/vim-jetpack/plugin/jetpack.vim"
local jetpackurl = "https://raw.githubusercontent.com/tani/vim-jetpack/master/plugin/jetpack.vim"
if vim.fn.filereadable(jetpackfile) == 0 then
  vim.fn.system(string.format("curl -fsSLo %s --create-dirs %s", jetpackfile, jetpackurl))
end

vim.cmd("packadd vim-jetpack")
-- run: :ではじめればコマンド、関数を渡せばcall、それ以外はsystem
require("jetpack.packer").add({
  -- manage itself
  { "tani/vim-jetpack", opt = 1 },
  -- Utility
  { "nvim-lua/plenary.nvim" },
  -- startup
  { "mhinz/vim-startify" },
  -- Preview
  { "previm/previm", requires = { "open-browser.vim" } },
  -- open URL
  { "tyru/open-browser.vim" },
  -- nonsense animation
  { "eandrju/cellular-automaton.nvim" },
  -- Window resize mode
  { "sedm0784/vim-resize-mode" },
  -- task runner
  { "Shougo/vimproc.vim", run = "make" },
  { "thinca/vim-quickrun" },
  -- diagnostics
  { "folke/trouble.nvim", requires = { "nvim-web-devicons" } },
  -- popup notification
  { "rcarriga/nvim-notify" },
  --- dependency
  { "kyazdani42/nvim-web-devicons" },
  -- Grammar check
  { "rhysd/vim-grammarous" },
  -- Ghosttext
  { "gamoutatsumi/dps-ghosttext.vim" },
  -- LSP
  { "neovim/nvim-lspconfig" },
  --- Installer
  { "williamboman/mason.nvim" },
  { "williamboman/mason-lspconfig.nvim", requires = { "nvim-lspconfig", "mason.nvim" } },
  { "mfussenegger/nvim-jdtls" },
  --- DAP
  { "mfussenegger/nvim-dap" },
  { "rcarriga/nvim-dap-ui", requires = { "nvim-dap" } },
  --- outliner
  { "simrat39/symbols-outline.nvim" },
  --- tsserver integration
  { "jose-elias-alvarez/typescript.nvim" },
  --- Formatter with LSP interface
  { "jose-elias-alvarez/null-ls.nvim", requires = { "plenary.nvim" } },
  { "MunifTanjim/prettier.nvim", requires = { "nvim-lspconfig", "null-ls.nvim" } },
  --- Rust tooltip
  { "simrat39/rust-tools.nvim" },
  -- Popup
  { "Shougo/pum.vim" },
  -- denops
  { "vim-denops/denops.vim" },
  { "vim-skk/skkeleton", requires = { "denops.vim" } },
  { "matsui54/denops-popup-preview.vim", requires = { "denops.vim" } },
  { "matsui54/denops-signature_help", requires = { "denops.vim" } },
  --- ddc
  { "Shougo/ddc.vim", requires = { "denops.vim" } },
  { "Shougo/ddc-nvim-lsp", requires = { "denops.vim", "ddc.vim" } },
  { "Shougo/ddc-around", requires = { "denops.vim", "ddc.vim" } },
  { "Shougo/ddc-matcher_head", requires = { "denops.vim", "ddc.vim" } },
  { "tani/ddc-fuzzy", requires = { "denops.vim", "ddc.vim" } },
  { "Shougo/ddc-sorter_rank", requires = { "denops.vim", "ddc.vim" } },
  { "LumaKernel/ddc-file", requires = { "denops.vim", "ddc.vim" } },
  ---- ui
  { "Shougo/ddc-ui-pum", requires = { "denops.vim", "ddc.vim", "pum.vim" } },
  --- ddu
  { "Shougo/ddu.vim", requires = { "denops.vim" } },
  { "Shougo/ddu-commands.vim", requires = { "denops.vim", "ddu.vim" } },
  ---- UI
  { "Shougo/ddu-ui-ff", requires = { "denops.vim", "ddu.vim" } },
  { "Shougo/ddu-ui-filer", requires = { "denops.vim", "ddu.vim" } },
  ---- Matcher
  { "Shougo/ddu-filter-matcher_substring", requires = { "denops.vim", "ddu.vim" } },
  { "Shougo/ddu-filter-matcher_hidden", requires = { "denops.vim", "ddu.vim" } },
  ---- Sources
  { "Shougo/ddu-source-action", requires = { "denops.vim", "ddu.vim" } },
  { "4513ECHO/ddu-source-source", requires = { "denops.vim", "ddu.vim" } },
  { "Shougo/ddu-source-file", requires = { "denops.vim", "ddu.vim" } },
  { "Shougo/ddu-source-file_rec", requires = { "denops.vim", "ddu.vim" } },
  { "shun/ddu-source-buffer", requires = { "denops.vim", "ddu.vim" } },
  { "shun/ddu-source-rg", requires = { "denops.vim", "ddu.vim" } },
  { "Shougo/ddu-source-register", requires = { "denops.vim", "ddu.vim" } },
  { "matsui54/ddu-source-command_history", requires = { "denops.vim", "ddu.vim" } },
  ---- Kinds
  { "Shougo/ddu-kind-file", requires = { "denops.vim", "ddu.vim" } },
  { "Shougo/ddu-kind-word", requires = { "denops.vim", "ddu.vim" } },
  ---- column
  { "Shougo/ddu-column-filename", requires = { "denops.vim", "ddu.vim" } },
  { "ryota2357/ddu-column-icon_filename", requires = { "denops.vim", "ddu.vim" } },
  -- filer
  { "lambdalisue/fern.vim", branch = "main" },
  { "lambdalisue/fern-renderer-nerdfont.vim", requires = { "nerdfont.vim" } },
  { "lambdalisue/nerdfont.vim" },
  { "lambdalisue/fern-hijack.vim" },
  -- for good appearance
  { "ryanoasis/vim-devicons" },
  -- other
  -- editorconfig
  { "editorconfig/editorconfig-vim" },
  -- git
  { "tpope/vim-fugitive" },
  -- parenthesis control
  { "rhysd/vim-operator-surround", requires = { "vim-operator-user" } },
  --- dependency
  { "kana/vim-operator-user" },
  -- autocomplete matching brace/quotation
  { "cohama/lexima.vim" },
  -- undo
  { "mbbill/undotree" },
  { "nvim-lualine/lualine.nvim", requires = { "nvim-web-devicons" } },
  -- comment out
  { "tomtom/tcomment_vim" },
  -- helpの日本語化
  { "vim-jp/vimdoc-ja" },
  -- ペースト時にpasteモードに
  { "ConradIrwin/vim-bracketed-paste" },
  -- show underscore for matching parenthesis
  { "itchyny/vim-parenmatch" },
  { "alvan/vim-closetag" },
  -- color scheme
  { "tomasr/molokai" },
  -- snippets
  { "Shougo/neosnippet.vim" },
  -- { 'Shougo/deoppet.nvim' },
  { "Shougo/neosnippet-snippets" },
  -- Template
  { "thinca/vim-template" },
  -- cursor
  { "rhysd/accelerated-jk" },
  { "skanehira/jumpcursor.vim" },
  -- Highlight under cursor
  { "RRethy/vim-illuminate" },
  -- indentation
  { "lambdalisue/vim-backslash" },
  { "hynek/vim-python-pep8-indent" },
  -- Syntax Highlighting
  { "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" },
  --- fish
  { "dag/vim-fish" },
  --- .gitignore file
  { "benknoble/gitignore-vim" },
  --- SATySFi
  { "qnighy/satysfi.vim" },
  --- F-
  { "ionide/Ionide-vim" },
  --- Brewfile
  { "bfontaine/Brewfile.vim" },
  --- ebuild etc
  { "gentoo/gentoo-syntax" },
  --- CoPL Derivation Language
  { "ymyzk/vim-copl" },
  --- CSV (Rainbow and SQL-like query)
  { "mechatroner/rainbow_csv" },
  --- Firestore Security Rule
  { "delphinus/vim-firestore" },
  --- skk-jisyo
  { "vim-skk/skkdict.vim" },
  { "fatih/vim-go", ft = { "go" } },
  { "jdonaldson/vaxe", ft = { "haxe" } },
  { "keith/swift.vim", ft = { "swift" } },
})

-- check and install
local jetpack = require("jetpack")
for _, name in ipairs(jetpack.names()) do
  if not jetpack.tap(name) then
    jetpack.sync()
    break
  end
end
