local overseer = require("overseer")
return {
    name = "latexmk",
    builder = function()
        return {
            cmd = "latexmk",
        }
    end,
    tags = { overseer.TAG.BUILD },
    condition = {
        filetype = { "tex" },
    },
}
