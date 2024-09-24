-- lua_post_source {{{
-- Debugging
local dap = require("dap")
local dap_ui = require("dapui")

-- local ensure_installed = {
--   "codelldb",
--   "debugpy",
--   "delve",
--   "java-debug-adapter",
--   "java-test",
--   "php-debug-adapter"
-- }

-- Debugger related: preceded by <Leader>d
dap_ui.setup({})
local opts_with_desc = function(desc)
    return { silent = true, desc = "Debug Adapter: " .. desc }
end
vim.keymap.set("n", "<Leader>dd", function()
    dap_ui.toggle({
        reset = true,
    })
end, opts_with_desc("Toggle UI"))
vim.keymap.set("n", "<Leader>dt", function()
    dap.toggle_breakpoint()
end, opts_with_desc("Toggle breakpoint"))
vim.keymap.set("n", "<Leader>dc", function()
    dap.toggle_breakpoint(vim.fn.input("Condition: "))
end, opts_with_desc("Toggle conditional breakpoint"))
vim.keymap.set("n", "<Leader>dr", dap.continue, opts_with_desc("Continue"))
vim.keymap.set("n", "<Leader>dp", dap.pause, opts_with_desc("Pause"))
vim.keymap.set("n", "<Leader>dx", dap.close, opts_with_desc("Close session"))
vim.keymap.set("n", "<Leader>ds", dap.step_over, opts_with_desc("Step over"))
vim.keymap.set("n", "<Leader>di", dap.step_into, opts_with_desc("Step into"))
vim.keymap.set("n", "<Leader>do", dap.step_out, opts_with_desc("Step out"))
vim.keymap.set("n", "<Leader>db", dap.step_back, opts_with_desc("Step back"))
vim.keymap.set("n", "<Leader>de", dap.set_exception_breakpoints, opts_with_desc("Set breakpoint on exceptions"))

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
        port = "9003",
    },
}
-- }}}
