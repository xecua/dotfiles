lua << EOF
local lsp_config = require('lspconfig')
lsp_config.pyright.setup{}

lsp_config.rust_analyzer.setup{}

lsp_config.clangd.setup{}

lsp_config.tsserver.setup{}

lsp_config.vimls.setup{}

lsp_config.html.setup{}
lsp_config.jsonls.setup{}

lsp_config.texlab.setup{}

lsp_config.gopls.setup{}
EOF
