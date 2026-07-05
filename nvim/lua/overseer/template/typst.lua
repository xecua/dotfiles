local overseer = require("overseer")
return {
    name = "typst",
    builder = function()
        local filename = vim.fn.expand("%:S")
        return {
            cmd = "typst",
            args = { "compile", "--diagnostic-format", "short", filename },
        }
    end,
    tags = { overseer.TAG.BUILD },
    condition = {
        filetype = { "typst" },
    },
}
