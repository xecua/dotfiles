vim.filetype.add({
    extension = {
        er = "python", -- erg
        hx = "haxe",
        mdc = "markdown",
    },
    pattern = {
        [".textlintrc"] = "json",
        ["docker%-compose%.ya?ml"] = "yaml.compose",
        ["compose%.ya?ml"] = "yaml.compose",
        ["openapi.*%.ya?ml"] = "yaml.openapi",
        ["openapi.*%.json"] = "json.openapi",
        [".*/%.vscode/.*%.json"] = "jsonc",
    },
})
