return {
    root_dir = function(bufnr, callback)
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

        local root_dir = vim.fs.root(bufnr, { ".git" })
        if root_dir then
            return callback(root_dir)
        end
    end,
    settings = {
        telemetry = {
            telemetryLevel = "off",
        },
    },
}
