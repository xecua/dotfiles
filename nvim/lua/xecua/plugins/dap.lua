-- lua_source {{{
-- Debugging
local dap = require("dap")
local dap_ui = require("dapui")

require("dap.ext.vscode").json_decode = require("json5").parse

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

    -- TODO: ストローク数多すぎ問題
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

dap.adapters = {
    python = {
        type = "executable",
        command = "debugpy-adapter",
    },
    codelldb = {
        type = "server",
        port = "${port}",
        executable = {
            command = "codelldb",
            args = { "--port", "${port}" },
        },
    },
    go = {
        type = "server",
        port = "${port}",
        executable = {
            command = "dlv",
            args = { "dap", "-l", "127.0.0.1:${port}" },
        },
    },
    php = {
        type = "executable",
        command = "php-debug-adapter",
    },
    coreclr = {
        type = "executable",
        command = "netcoredbg",
        args = { "--interpreter=vscode" },
    },
}

-- }}}
