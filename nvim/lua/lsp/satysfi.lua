local configs = require("lspconfig.configs")
local util = require("lspconfig.util")
local server = require("nvim-lsp-installer.server")
local servers = require("nvim-lsp-installer.servers")
local path = require("nvim-lsp-installer.path")
local installers = require("nvim-lsp-installer.installers")
local std = require("nvim-lsp-installer.installers.std")
local shell = require("nvim-lsp-installer.installers.shell")

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

local installer = installers.pipe({
  std.git_clone("https://github.com/monaqa/satysfi-language-server.git"),
  shell.polyshell("cargo build --release"),
  std.rename("target/release/satysfi-language-server", "satysfi-language-server"),
})

local satysfi_ls = server.Server:new({
  name = server_name,
  root_dir = root_dir,
  installer = installer,
  default_options = {
    cmd = {
      path.concat({ root_dir, "satysfi-language-server" }),
    },
  },
})

servers.register(satysfi_ls)
