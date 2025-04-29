-- lua_source {{{
-- these still need lagacy configs https://github.com/neovim/nvim-lspconfig/issues/3705
local lspconfig = require("lspconfig")

lspconfig.astro.setup({})
lspconfig.eslint.setup({ settings = { eslint = { autoFixOnSave = true } } })
-- }}}
