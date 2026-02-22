-- lua_add {{{
vim.keymap.set("n", "<Leader>dt", "<Cmd>DapToggleBreakpoint<CR>", { silent = true })
vim.keymap.set("n", "<F5>", "<Cmd>DapContinue<CR>", { silent = true })
vim.keymap.set("n", "<F6>", "<Cmd>DapStepOver<CR>", { silent = true })
vim.keymap.set("n", "<F7>", "<Cmd>DapStepInto<CR>", { silent = true })
vim.keymap.set("n", "<F8>", "<Cmd>DapStepOut<CR>", { silent = true })
vim.keymap.set("n", "<Leader>dx", "<Cmd>DapTerminate<CR>", { silent = true })
vim.keymap.set("n", "<Leader>de", function()
    require("dap").set_exception_breakpoints()
end, { silent = true, desc = "DAP: Set exception breakpoints" })
vim.keymap.set("n", "<Leader>dc", function()
    vim.ui.input({ prompt = "Condition: " }, function(cond)
        require("dap").toggle_breakpoint(cond)
    end)
end, { silent = true, desc = "DAP: Toggle conditional breakpoint" })
vim.keymap.set("n", "<F9>", function()
    require("dap").step_back()
end, { silent = true, desc = "DAP: Step back" })
-- }}}

-- lua_source {{{
require("dap.ext.vscode").json_decode = require("json5").parse
require("dap").adapters = {
    python = { type = "executable", command = "debugpy-adapter" },
    codelldb = {
        type = "server",
        port = "${port}",
        executable = { command = "codelldb", args = { "--port", "${port}" } },
    },
    go = function(on_config, launchArgs)
        local config = {
            type = "server",
        }
        if launchArgs.request == "attach" and config.mode == "remote" then
            -- このときだけはdlv dapは仲介してくれない(helpに列挙されてない)
            -- でpathMappingってどうやんの??
            config.port = launchArgs.port or 2345 -- delve default
            if launchArgs.host then
                config.host = launchArgs.host
            end
        else
            -- dlv dap(configの解釈含めて全部やってくれる)を利用
            config.port = "${port}"
            config.executable = { command = "dlv", args = { "dap", "-l", "127.0.0.1:${port}" } }
        end
        on_config(config)
    end,
    php = { type = "executable", command = "php-debug-adapter" },
    coreclr = {
        type = "executable",
        command = "netcoredbg",
        args = { "--interpreter=vscode" },
    },
}
-- }}}
