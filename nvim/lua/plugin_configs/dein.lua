local dein_dir = vim.fn.stdpath("cache") .. "/dein"
local dein_repo_dir = dein_dir .. "/repos/github.com/Shougo/dein.vim"

-- bootstrap
-- vim.o: get option as string (unlike vim.opt:get)-> utilize string.find
if not vim.o.rtp:find("/dein.vim") then
  if vim.fn.isdirectory(dein_repo_dir) then
    -- todo: clone
    vim.fn.execute("!git clone https://github.com/Shougo/dein.vim " .. dein_repo_dir)
  end

  vim.opt.rtp:prepend(dein_repo_dir)
end

local dein = require("dein")
if dein.load_state(dein_dir) == 1 then
  dein.begin(dein_dir)

  dein.load_toml(vim.fn.stdpath("config") .. "/dein.toml", { lazy = 0 })
  dein.load_toml(vim.fn.stdpath("config") .. "/dein_lazy.toml", { lazy = 1 })

  dein.end_()
  dein.save_state()
end

if dein.check_install() then
  dein.install()
end

vim.api.nvim_create_user_command("DeinClean", "call map(dein#check_clean(), { _, val -> delete(val, 'rf') })", {})
