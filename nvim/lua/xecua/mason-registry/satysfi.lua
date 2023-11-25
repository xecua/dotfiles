local Pkg = require('mason-core.package')
local cargo = require('mason-core.managers.cargo')

local github_url = 'https://github.com/monaqa/satysfi-language-server'

return Pkg.new({
  name = 'satysfi',
  desc = 'SATySFi language server',
  homepage = github_url,
  languages = { Pkg.Lang.SATySFi },
  categories = { Pkg.Cat.LSP },
  install = cargo.crate('satysfi-language-server', { git = { url = github_url }, bin = { 'satysfi-language-server' } }),
})
