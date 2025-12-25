return {
    root_dir = function(bufnr, on_dir)
        local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
        if
            vim.tbl_contains({
                "markdown",
                "dap-repl",
                "dapui_watches",
                "dapui_scopes",
                "dapui_console",
                "AvanteInput",
            }, filetype)
        then
            return
        end

        return on_dir(vim.fs.root(bufnr, { ".git" }))
    end,
    settings = {
        telemetry = {
            telemetryLevel = "off",
        },
    },
}
