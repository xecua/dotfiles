local registry = require("mason-registry")
local lspconfig = require("lspconfig")
local mason_lspconfig = require("mason-lspconfig")

mason_lspconfig.setup({
  ensure_installed = {
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
    -- "satysfi-ls",
    "lemminx",
    "taplo",
    -- note: non-lsp servers are not considered: https://github.com/williamboman/mason.nvim/discussions/143#discussioncomment-3225734
  },
  -- automatic_installation = false,
})

local on_attach = function(client, bufnr)
  -- local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- Enable completion triggered by <c-x><c-o>
  -- buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { buffer = bufnr, silent = true }

  -- LSP related: preceded by <Leader>i
  vim.keymap.set("n", "<Leader>id", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "<Leader>it", vim.lsp.buf.type_definition, opts)
  vim.keymap.set("n", "<Leader>ii", vim.lsp.buf.implementation, opts)
  vim.keymap.set("n", "<Leader>ir", vim.lsp.buf.references, opts)
  vim.keymap.set("n", "<Leader>i]", vim.diagnostic.goto_next, opts)
  vim.keymap.set("n", "<Leader>i[", vim.diagnostic.goto_prev, opts)
  vim.keymap.set("n", "<Leader>ia", vim.lsp.buf.code_action, opts)
  vim.keymap.set("n", "<Leader>im", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, opts)

  if client.server_capabilities.documentFormattingProvider then
    vim.keymap.set("n", "<Leader>if", vim.lsp.buf.format, opts)
  end

  if client.server_capabilities.documentRangeFormattingProvider then
    vim.keymap.set("v", "<Leader>if", vim.lsp.buf.format, opts)
  end

  vim.api.nvim_buf_create_user_command(bufnr, "Format", vim.lsp.buf.format, {})
end

mason_lspconfig.setup_handlers({
  function(server_name)
    local utils = require("utils")
    local ignore_servers = { "jdtls" }
    if utils.find(server_name, ignore_servers) == -1 then
      lspconfig[server_name].setup({
        on_attach = on_attach,
      })
    end
  end,
  rust_analyzer = function()
    local dap_config = {}
    if registry.is_installed("codelldb") then
      local pkg_dir = registry.get_package("codelldb"):get_install_path()
      dap_config = {
        adapter = require("rust-tools.dap").get_codelldb_adapter(
          pkg_dir .. "/extension/adapter/codelldb",
          pkg_dir .. "/extension/lldb/lib/liblldb.so"
        ),
      }
    end
    local rust_tools = require("rust-tools")
    rust_tools.setup({
      tools = {
        hover_actions = { border = "single", auto_focus = true }, -- default cause error (those of cica has double width)
      },
      server = {
        on_attach = function(client, bufnr)
          on_attach(client, bufnr)
          -- overwrite default configs
          vim.keymap.set("n", "<Leader>ih", rust_tools.hover_actions.hover_actions, { buffer = bufnr, silent = true })
          vim.keymap.set(
            "n",
            "<Leader>ia",
            rust_tools.code_action_group.code_action_group,
            { buffer = bufnr, silent = true }
          )
        end,
      },
      dap = dap_config,
    })
  end,
  sumneko_lua = function()
    local runtime_path = vim.split(package.path, ";")
    table.insert(runtime_path, "lua/?.lua")
    table.insert(runtime_path, "lua/?/init.lua")
    lspconfig.sumneko_lua.setup({
      on_attach = on_attach,
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
    local forward_search_config = {}
    if vim.g.os == "Linux" then
      forward_search_config = {
        executable = "zathura",
        args = { "--synctex-forward", "%l:1:%f", "%p" },
      }
    elseif vim.g.os == "Windows" then
      forward_search_config = {
        executable = "SumatraPDF.exe", -- PATHに入れちゃうのがいいかなあ
        args = { "-reuse-instance", "%p", "-forward-search", "%f", "%l" }
      }
    elseif vim.g.os == "Darwin" then
      forward_search_config = {
        executable = "/Applications/Skim.app/Contents/SharedSupport/displayline",
        args = { "%l", "%p", "%f" }
      }
    end

    lspconfig.texlab.setup({
      on_attach = on_attach,
      settings = {
        -- currently not supported? (https://github.com/latex-lsp/texlab/issues/427)
        texlab = {
          auxDirectory = "./out",
          build = {
            args = {},
          },
          forwardSearch = forward_search_config,
        },
      },
    })
  end,
  eslint = function()
    lspconfig.eslint.setup({
      on_attach = function(client, bufnr)
        client.server_capabilities.documentFormattingProvider = true
        on_attach(client, bufnr)
      end,
      settings = {
        format = { enable = true },
      },
    })
  end,
  jsonls = function()
    lspconfig.jsonls.setup({
      on_attach = on_attach,
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
      },
    })
  end,
})

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "java" },
  callback = function()
    -- setting up jdtls (this does not works when call in setup_handlers)
    local pkg_dir = registry.get_package("jdtls"):get_install_path()
    local jdtls = require("jdtls")
    local jar_path = vim.fn.glob(pkg_dir .. "/plugins/org.eclipse.equinox.launcher_*.jar")
    local system = "linux"
    if vim.g.os == "Windows" then
      system = "win"
    elseif vim.g.os == "WSL" then
      system = "linux"
    elseif vim.g.os == "Darwin" then
      system = "mac"
    end
    local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")

    -- DAP: both of java-debug-adapter and java-test are ought to be installed. (https://github.com/mfussenegger/nvim-jdtls#debugger-via-nvim-dap)
    local debug_adapter_dir = registry.get_package("java-debug-adapter"):get_install_path()
    local java_test_dir = registry.get_package("java-test"):get_install_path()

    local bundles = { vim.fn.glob(debug_adapter_dir .. "/extension/server/com.microsoft.java.debug.plugin-*.jar") }
    vim.list_extend(bundles, vim.split(vim.fn.glob(java_test_dir .. "/extension/server/*.jar"), "\n"))

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
        vim.env.HOME .. "/Documents/eclipse-workspace/jdt.ls/" .. project_name,
      },
      on_attach = function(client, bufnr)
        local opts = { buffer = bufnr, silent = true }
        vim.keymap.set("n", "<Leader>io", jdtls.organize_imports, opts)
        vim.keymap.set("n", "<Leader>dc", jdtls.test_class, opts)
        vim.keymap.set("n", "<Leader>dm", jdtls.test_nearest_method, opts)

        jdtls.setup_dap({ hotcodereplace = "auto" })

        -- exposed commands
        require("jdtls.setup").add_commands()

        on_attach(client, bufnr)
      end,
      init_options = { bundles = bundles },
    })
  end,
})
