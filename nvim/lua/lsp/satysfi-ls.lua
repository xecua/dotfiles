local configs = require("lspconfig.configs")
local util = require("lspconfig.util")
local server = require("nvim-lsp-installer.server")
local servers = require("nvim-lsp-installer.servers")
local path = require("nvim-lsp-installer.core.path")
local cargo = require("nvim-lsp-installer.core.managers.cargo")

local server_name = "satysfi-ls"

configs[server_name] = {
  default_config = {
    filetypes = { "satysfi" },
    root_dir = function(fname) -- from vimls.lua
      return util.find_git_ancestor(fname) or vim.fn.getcwd()
    end,
  },
}

local root_dir = server.get_server_root_path(server_name)

local satysfi_ls = server.Server:new({
  name = server_name,
  root_dir = root_dir,
  async = true,
  installer = cargo.crate(
    "https://github.com/monaqa/satysfi-language-server.git",
    { git = true }
  ),
  default_options = {
    cmd = {
      path.concat({ root_dir, "satysfi-language-server" }),
    },
  },
})

servers.register(satysfi_ls)
