-- register custom server
require("lsp.satysfi-ls")
local index = require("mason-registry.index")
index["satysfi-ls"] = "lsp.satysfi-ls"

-- setup
local registry = require("mason-registry")
local lspconfig = require("lspconfig")

local mason = require("mason")
mason.setup()
local mason_lspconfig = require("mason-lspconfig")
mason_lspconfig.setup({
  -- めも(doc読んでもよくわからなくなりがちなので)
  -- ここに挙げたものは必ずインストールされる(そしてsetupを呼ばずとも実行される?)
  ensure_installed = {
    "pyright",
    "rust_analyzer",
    "clangd",
    -- "dartls", -- not registered in mason, because dartls is  dart compiler (https://github.com/williamboman/mason.nvim/issues/136)
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
    "satysfi-ls",

    "codelldb",
    "java-debug-adapter"
  },
  -- lspconfig.setupで呼ばれたのにインストールされていないものは(masonで)インストールされる
  -- そういうのはセットアップしないと思うのでfalse(default)でいいや
  automatic_installation = false,
})

local on_attach = function(client, bufnr)
  local function buf_set_keymap(...)
    vim.api.nvim_buf_set_keymap(bufnr, ...)
  end

  -- local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- Enable completion triggered by <c-x><c-o>
  -- buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap = true, silent = true }

  buf_set_keymap("n", "gd", "<Cmd>lua vim.lsp.buf.definition()<CR>", opts)
  buf_set_keymap("n", "gy", "<Cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
  buf_set_keymap("n", "gi", "<Cmd>lua vim.lsp.buf.implementation()<CR>", opts)
  buf_set_keymap("n", "gr", "<Cmd>lua vim.lsp.buf.references()<CR>", opts)
  buf_set_keymap("n", "]g", "<Cmd>lua vim.lsp.diagnostic.goto_next()<CR>", opts)
  buf_set_keymap("n", "[g", "<Cmd>lua vim.lsp.diagnostic.goto_prev()<CR>", opts)
  buf_set_keymap("n", "<F2>", "<Cmd>lua vim.lsp.buf.rename()<CR>", opts)
  buf_set_keymap("n", "<Leader>i", "<Cmd>lua vim.lsp.buf.code_action()<CR>", opts)
  buf_set_keymap("n", "<Leader>m", "<Cmd>lua vim.lsp.buf.hover()<CR>", opts)

  if client.resolved_capabilities.document_formatting then
    buf_set_keymap("n", "<Leader>f", "<Cmd>lua vim.lsp.buf.formatting()<CR>", opts)
  end

  if client.resolved_capabilities.document_range_formatting then
    buf_set_keymap("v", "<Leader>f", "<Cmd>lua vim.lsp.buf.range_formatting()<CR>", opts)
  end
end

local commands = {
  Format = {
    function()
      vim.lsp.buf.formatting()
    end,
  },
}

mason_lspconfig.setup_handlers({
  function(server_name)
    lspconfig[server_name].setup({
      on_attach = on_attach,
      commands = commands,
    })
  end,
  ["rust_analyzer"] = function()
    require("rust-tools").setup({
      server = {
        on_attach = on_attach,
        commands = commands,
      },
    })
  end,
  ["sumneko_lua"] = function()
    local runtime_path = vim.split(package.path, ";")
    table.insert(runtime_path, "lua/?.lua")
    table.insert(runtime_path, "lua/?/init.lua")
    lspconfig.sumneko_lua.setup({
      on_attach = on_attach,
      commands = commands,
      settings = {
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
          format = {
            enable = false, -- とりあえずstyluaでいいかな……?
          },
        },
      },
    })
  end,
  texlab = function()
    lspconfig.texlab.setup({
      on_attach = on_attach,
      commands = commands,
      settings = {
        -- currently not supported? (https://github.com/latex-lsp/texlab/issues/427)
        texlab = {
          auxDirectory = "./out",
          build = {
            args = {},
          },
        },
      },
    })
  end,
  eslint = function()
    lspconfig.eslint.setup({
      on_attach = function(client, bufnr)
        client.resolved_capabilities.document_formatting = true
        on_attach(client, bufnr)
      end,
      commands = commands,
      settings = {
        format = { enable = true },
      },
    })
  end,
  jsonls = function()
    lspconfig.jsonls.setup({
      on_attach = on_attach,
      commands = commands,
      init_options = {
        provideFormatter = false,
      },
    })
  end,
  tsserver = function()
    -- https://github.com/jose-elias-alvarez/typescript.nvim#setup
    require("typescript").setup({
      disable_commands = false, -- prevent the plugin from creating Vim commands
      debug = false, -- enable debug logging for commands
      go_to_source_definition = {
        fallback = true, -- fall back to standard LSP definition on failure
      },
      server = {
        on_attach = on_attach,
        commands = commands,
      },
    })
  end,
  jdtls = function()
    if vim.bo.filetype ~= 'java' then
      return
    end
    -- https://github.com/mfussenegger/nvim-jdtls/issues/156#issuecomment-999943363
    local pkg_dir = registry.get_package("jdtls"):get_install_path()
    local jdtls = require("jdtls")
    local jar_path = vim.fn.glob(
      require("mason-registry").get_package("jdtls"):get_install_path() .. "/plugins/org.eclipse.equinox.launcher_*.jar"
    )
    local system = "linux"
    if vim.g.os == "Windows" then
      system = "win"
    elseif vim.g.os == "Darwin" then
      system = "mac"
    end
    local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")

    jdtls.start_or_attach({
      -- masonが入れた付属の`jdtls`(pythonスクリプト)はfull-featureには使えない?
      cmd = {
        "java",
        "-Declipse.application=org.eclipse.jdt.ls.core.id1",
        "-Dosgi.bundles.defaultStartLevel=4",
        "-Declipse.product=org.eclipse.jdt.ls.core.product",
        "-Dlog.protocol=true",
        "-Dlog.level=ALL",
        "-Xms1g",
        "--add-modules=ALL-SYSTEM",
        "--add-opens",
        "java.base/java.util=ALL-UNNAMED",
        "-jar",
        jar_path,
        "-configuration",
        pkg_dir .. "/config_" .. system,
        -- See `data directory configuration` section in the README
        "-data",
        vim.env.HOME .. "/Documents/eclipse-workspace/jdt.ls" .. project_name,
      },
      on_attach = on_attach,
      commands = commands,
    })
  end,
})

-- for _, name in pairs(servers) do
--   local opts = {
--     on_attach = on_attach,
--     commands = commands,
--   }
--   if name == "jdtls" then
--     if vim.bo.filetype == "java" then
--       local lsp_installer_servers = require("nvim-lsp-installer.servers")
--       local jdtls = require("jdtls")
--       local _, jdtls_config = lsp_installer_servers.get_server("jdtls")
--       opts.cmd = jdtls_config:get_default_options().cmd
--       jdtls.start_or_attach(opts)
--       goto continue
--     end
--   end

-- null-ls: not LSP, used for formatting etc
local null_ls = require("null-ls")
null_ls.setup({
  sources = {
    null_ls.builtins.formatting.stylua.with({
      extra_args = { "--indent-type", "Spaces", "--indent-width", "2" },
    }),
    null_ls.builtins.formatting.yapf,
    null_ls.builtins.formatting.xmllint,
  },
  on_attach = function(client, bufnr)
    if client.resolved_capabilities.document_formatting then
      vim.api.nvim_buf_set_keymap(bufnr, "n", "<Leader>f", "<Cmd>lua vim.lsp.buf.formatting()<CR>", {
        noremap = true,
        silent = true,
      })
    end

    if client.resolved_capabilities.document_range_formatting then
      vim.api.nvim_buf_set_keymap(bufnr, "x", "<Leader>f", "<Cmd>lua vim.lsp.buf.range_formatting({})<CR>", {
        noremap = true,
        silent = true,
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
local trouble = require("trouble")
trouble.setup({})

-- debugging
local dap = require('dap')
local dap_ui = require('dapui')

dap_ui.setup({})
