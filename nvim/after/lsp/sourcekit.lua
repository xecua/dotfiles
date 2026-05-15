-- Xcodeプロジェクトでだけ起動してほしい
return {
    root_dir = function(bufnr, on_dir)
        local util = require("lspconfig.util")
        local filename = vim.api.nvim_buf_get_name(bufnr)
        local target = util.root_pattern("buildServer.json", ".bsp")(filename)
            or util.root_pattern("*.xcodeproj", "*.xcworkspace")(filename)
            or util.root_pattern("compile_commands.json", "Package.swift")(filename)
        if target then
            on_dir(target)
        end
    end,
}
