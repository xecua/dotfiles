-- server installation
require('lsp.satysfi-ls')

local lsp_installer = require("nvim-lsp-installer")
lsp_installer.setup({
  automatic_installation = true
})

local lspconfig = require("lspconfig")

local servers = {
  "pyright",
  "rust_analyzer",
  "clangd",
  "dartls",
  "tsserver",
  "vimls",
  "html",
  "gopls",
  "kotlin_language_server",
  "jdtls",
  "jsonls",
  "texlab",
  "eslint",
  "sumneko_lua",
  "satysfi-ls"
}

-- server configuratiion
local ts_utils = require('nvim-lsp-ts-utils')

local on_attach = function(client, bufnr)
  local function buf_set_keymap(...)
    vim.api.nvim_buf_set_keymap(bufnr, ...)
  end
  -- local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- Enable completion triggered by <c-x><c-o>
  -- buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap = true, silent = true }

  buf_set_keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
  buf_set_keymap("n", "gy", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
  buf_set_keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
  buf_set_keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
  buf_set_keymap("n", "]g", "<cmd>lua vim.lsp.diagnostic.goto_next()<CR>", opts)
  buf_set_keymap("n", "[g", "<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>", opts)
  buf_set_keymap("n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
  buf_set_keymap("n", "<leader>i", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
  buf_set_keymap("n", "<leader>m", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)

  if client.resolved_capabilities.document_formatting then
    buf_set_keymap("n", "<leader>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
  end

  if client.resolved_capabilities.document_range_formatting then
    buf_set_keymap("v", "<leader>f", "<cmd>lua vim.lsp.buf.range_formatting()<CR>", opts)
  end
end

local commands = {
  Format = {
    function()
      vim.lsp.buf.formatting()
    end,
  },
}

for _, name in pairs(servers) do
  local opts = {
    on_attach = on_attach,
    commands = commands,
  }

  if name == "eslint" then
    opts.on_attach = function(client, bufnr)
      client.resolved_capabilities.document_formatting = true
      on_attach(client, bufnr)
    end
    opts.settings = {
      format = { enable = true },
    }
  end

  if name == "jsonls" then
    opts.init_options = {
      provideFormatter = false,
    }
  end

  -- currently not supported? (https://github.com/latex-lsp/texlab/issues/427)
  -- if server.name == "texlab" then
  --   opts.settings = {
  --       texlab = {
  --           auxDirectory = "./out",
  --           build = {
  --               args = {},
  --               onSave = true
  --           }
  --       }
  --   }
  -- end

  if name == "tsserver" then
    -- integrate ts-utils
    opts.init_options = ts_utils.init_options
    opts.on_attach = function(client, bufnr)
      ts_utils.setup({ debug = false })
      ts_utils.setup_client(client)
      on_attach(client, bufnr)
    end
  end

  if name == "sumneko_lua" then
    local runtime_path = vim.split(package.path, ";")
    table.insert(runtime_path, "lua/?.lua")
    table.insert(runtime_path, "lua/?/init.lua")
    opts.settings = {
      Lua = {
        runtime = {
          -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
          version = "LuaJIT",
          -- Setup your lua path
          path = runtime_path,
        },
        diagnostics = {
          -- Get the language server to recognize the `vim` global
          globals = { "vim" },
        },
        workspace = {
          -- Make the server aware of Neovim runtime files
          library = vim.api.nvim_get_runtime_file("", true),
        },
        -- Do not send telemetry data containing a randomized but unique identifier
        telemetry = {
          enable = false,
        },
      },
    }
  end

  -- https://github.com/mfussenegger/nvim-jdtls/issues/156#issuecomment-999943363
  if name == "jdtls" then
    if vim.bo.filetype == "java" then
      local lsp_installer_servers = require("nvim-lsp-installer.servers")
      local jdtls = require("jdtls")
      local _, jdtls_config = lsp_installer_servers.get_server("jdtls")
      opts.cmd = jdtls_config:get_default_options().cmd
      jdtls.start_or_attach(opts)
      goto continue
    end
  end

  -- https://github.com/williamboman/nvim-lsp-installer/wiki/Rust
  if name == "rust_analyzer" then
    local rust_tools = require("rust-tools")
    rust_tools.setup({})
  end

  lspconfig[name].setup(opts)

  ::continue::
end

-- null-ls: not LSP, used for formatting etc
local null_ls = require("null-ls")
null_ls.setup({
  sources = {
    null_ls.builtins.formatting.stylua.with({
      extra_args = { "--indent-type", "Spaces", "--indent-width", "2" },
    }),
    null_ls.builtins.formatting.yapf,
    null_ls.builtins.formatting.xmllint
  },
  on_attach = function(client, bufnr)
    if client.resolved_capabilities.document_formatting then
      vim.api.nvim_buf_set_keymap(bufnr, "n", "<Leader>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", {
        noremap = true,
        silent = true,
      })
    end

    if client.resolved_capabilities.document_range_formatting then
      vim.api.nvim_buf_set_keymap(bufnr, "x", "<Leader>f", "<cmd>lua vim.lsp.buf.range_formatting({})<CR>", {
        noremap = true,
        silent = true
      })
    end
  end,
  commands = commands,
})

local prettier = require("prettier")
prettier.setup({
  bin = "prettier", -- or `prettierd`
  filetypes = {
    "css",
    "graphql",
    "html",
    "javascript",
    "javascript.jsx",
    "javascriptreact",
    "json",
    "less",
    "markdown",
    "sss",
    "typescript",
    "typescript.tsx",
    "typescriptreact",
    "yaml",
  },
})

-- Diagnostics
local trouble = require('trouble')
trouble.setup({})
