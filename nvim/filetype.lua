vim.filetype.add({
    extension = {
        tsx = "typescriptreact",
        jsx = "typescriptreact",
        er = "python", -- erg
        hx = "haxe",
        mdc = "markdown",
        frag = "glsl",
        vert = "glsl",
    },
    pattern = {
        [".*/git/config.*"] = "gitconfig",
        [".*/git/ignore.*"] = "gitignore", -- cause error?
        ["%.gitconfig.*"] = "gitconfig",
        [".*/git/attributes.*"] = "gitattributes",
        [".textlintrc"] = "json",
        [".*/hypr/.*%.conf"] = "hyprlang",
        ["docker%-compose%.ya?ml"] = "yaml.docker-compose",
        ["compose%.ya?ml"] = "yaml.docker-compose",
        ["openapi.*%.ya?ml"] = "yaml.openapi",
        ["openapi.*%.json"] = "json.openapi",
        [".*/%.vscode/.*%.json"] = "jsonc",
    },
})
