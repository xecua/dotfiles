local languages = require("xecua.plugins.efmls")
return {
    filetypes = vim.tbl_keys(languages),
    init_options = {
        documentFormatting = true,
        documentRangeFormatting = true,
    },
    settings = { languages = languages },
}
