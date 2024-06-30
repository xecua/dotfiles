vim.filetype.add({
  extension = {
    tsx = 'typescriptreact',
    jsx = 'typescriptreact',
    er = 'python', -- erg
    hx = 'haxe',
    frag = 'glsl',
    vert = 'glsl',
  },
  pattern = {
    ['.*/git/config.*'] = { 'gitconfig', { priority = 10 } },
    -- [".*/git/ignore.*"] = { "gitignore", { priority = 10 } }, -- cause error?
    ['%.gitconfig.*'] = { 'gitconfig', { priority = 10 } },
    ['.*/git/attributes.*'] = { 'gitattributes', { priority = 10 } },
    ['.*/nvim/template/.*'] = { 'vim', { priority = 10 } },
    ['.textlintrc'] = { 'json', { priority = 10 } },
    ['.*/hypr/.*%.conf'] = { 'hyprlang', { priority = 10 } },
  },
})
