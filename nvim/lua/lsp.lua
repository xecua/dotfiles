-- server installation
local lsp_installer = require("nvim-lsp-installer")
local servers = {
  "pyright",
  "rust_analyzer",
  "clangd",
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
}

for _, name in pairs(servers) do
  local server_is_found, server = lsp_installer.get_server(name)
  if server_is_found then
    if not server:is_installed() then
      print("Installing " .. name)
      server:install()
    end
  end
end

-- server configuratiion
local null_ls = require("null-ls")
local prettier = require("prettier")
local jdtls = require("jdtls")

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

lsp_installer.on_server_ready(function(server)
  local opts = {
    on_attach = on_attach,
    commands = commands,
  }

  if server.name == "eslint" then
    opts.on_attach = function(client, bufnr)
      client.resolved_capabilities.document_formatting = true
      on_attach(client, bufnr)
    end
    opts.settings = {
      format = { enable = true },
    }
  end

  if server.name == "jsonls" then
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

  if server.name == "sumneko_lua" then
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
  if server.name == "jdtls" then
    if vim.bo.filetype == "java" then
      local _, jdtls_config = lsp_installer.servers.get_server("jdtls")
      opts.cmd = jdtls_config.cmd
      jdtls.start_or_attach(opts)
      return
    end
  end

  server:setup(opts)
end)

-- null-ls: not LSP, used for formatting etc
null_ls.setup({
  sources = {
    null_ls.builtins.formatting.stylua.with({
      extra_args = { "--indent-type", "Spaces", "--indent-width", "2" },
    }),
  },
  on_attach = function(client, _)
    if client.resolved_capabilities.document_formatting then
      vim.cmd("nnoremap <silent><buffer> <Leader>f :lua vim.lsp.buf.formatting()<CR>")
    end

    if client.resolved_capabilities.document_range_formatting then
      vim.cmd("xnoremap <silent><buffer> <Leader>f :lua vim.lsp.buf.range_formatting({})<CR>")
    end
  end,
  commands = commands,
})

prettier.setup({
  bin = "prettier", -- or `prettierd`
  filetypes = {
    "css",
    "graphql",
    "html",
    "javascript",
    "javascriptreact",
    "json",
    "less",
    "markdown",
    "sss",
    "typescript",
    "typescriptreact",
    "yaml",
  },
})
