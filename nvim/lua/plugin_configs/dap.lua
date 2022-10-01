-- Debugging
local dap = require("dap")
local dap_ui = require("dapui")

-- preferred (via Mason?): codelldb, java-debug-adapter, debugpy, etc

-- Debugger related: preceded by <Leader>d
dap_ui.setup({})
vim.keymap.set("n", "<Leader>dd", dap_ui.toggle, { silent = true })
vim.keymap.set("n", "<Leader>dt", dap.toggle_breakpoint, { silent = true })
vim.keymap.set("n", "<Leader>dr", dap.continue, { silent = true })
vim.keymap.set("n", "<Leader>dp", dap.pause, { silent = true })
vim.keymap.set("n", "<Leader>dx", dap.close, { silent = true })
vim.keymap.set("n", "<Leader>ds", dap.step_over, { silent = true })
vim.keymap.set("n", "<Leader>di", dap.step_into, { silent = true })
vim.keymap.set("n", "<Leader>do", dap.step_out, { silent = true })
vim.keymap.set("n", "<Leader>db", dap.step_back, { silent = true })

-- Rust: configured in mason-lsp.lua (rust-tools offers better annotation)
-- Some plugins(e.g. rust-tools) may be set dap.adapters, so set whole dap.adapters is not preferred
dap.adapters.python = {
  type = "executable",
  command = vim.fn.exepath("debugpy-adapter"), -- mason
}
dap.adapters.codelldb = {
  type = "server",
  port = "${port}",
  executable = {
    command = vim.fn.exepath("codelldb"),
    args = { "--port", "${port}" },
  },
}
dap.adapters.go = {
  type = "server",
  port = "${port}",
  executable = {
    command = "dlv",
    args = { "dap", "-l", "127.0.0.1:${port}" },
  },
}
dap.adapters.php = {
  type = "executable",
  command = "php-debug-adapter", -- mason
}

local lldb_config = {
  {
    name = "Launch file",
    type = "codelldb",
    request = "launch",
    program = function()
      return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
    end,
    cwd = "${workspaceFolder}",
    stopOnEntry = true,
  },
}

-- As same reason as above, configure for each languages
dap.configurations.c = lldb_config
dap.configurations.cpp = lldb_config
-- dap.configurations.rust = lldb_config
dap.configurations.python = {
  {
    type = "python",
    request = "launch",
    name = "Launch file",
    program = "${file}",
  },
}
dap.configurations.go = {
  {
    type = "delve",
    name = "Debug",
    request = "launch",
    program = "${file}",
  },
  {
    type = "delve",
    name = "Debug test", -- configuration for debugging test files
    request = "launch",
    mode = "test",
    program = "${file}",
  },
  -- works with go.mod packages and sub packages
  {
    type = "delve",
    name = "Debug test (go.mod)",
    request = "launch",
    mode = "test",
    program = "./${relativeFileDirname}",
  },
}
dap.configurations.php = {
  {
    type = "php",
    request = "launch",
    name = "Listen for Xdebug",
    port = "9000",
  },
}
