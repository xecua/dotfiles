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
    local opts = { silent = true }
    if desc ~= nil then
        opts.desc = "Debug Adapter: " .. desc
    end
    return opts
end
vim.keymap.set("n", "<Leader>dd", function()
    dap_ui.toggle({
        reset = true,
    })
end, opts_with_desc("Toggle UI"))

vim.keymap.set("n", "<Leader>dt", "<Cmd>DapToggleBreakpoint<CR>", opts_with_desc())
vim.keymap.set("n", "<Leader>dx", "<Cmd>DapTerminate<CR>", opts_with_desc())
vim.keymap.set("n", "<Leader>de", dap.set_exception_breakpoints, opts_with_desc("Set breakpoint on exceptions"))
vim.keymap.set("n", "<Leader>dc", function()
    dap.toggle_breakpoint(vim.fn.input("Condition: "))
end, opts_with_desc("Toggle conditional breakpoint"))

vim.keymap.set("n", "<F5>", "<Cmd>DapContinue<CR>", opts_with_desc())
vim.keymap.set("n", "<F6>", "<Cmd>DapStepOver<CR>", opts_with_desc())
vim.keymap.set("n", "<F7>", "<Cmd>DapStepInto<CR>", opts_with_desc())
vim.keymap.set("n", "<F8>", "<Cmd>DapStepOut<CR>", opts_with_desc())
vim.keymap.set("n", "<F9>", dap.step_back, opts_with_desc("Step back"))

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
