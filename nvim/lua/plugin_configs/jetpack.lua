-- bootstrap
local jetpackfile = vim.fn.stdpath("data") .. "/site/pack/jetpack/opt/vim-jetpack/plugin/jetpack.vim"
local jetpackurl = "https://raw.githubusercontent.com/tani/vim-jetpack/master/plugin/jetpack.vim"
if vim.fn.filereadable(jetpackfile) == 0 then
  vim.fn.system(string.format("curl -fsSLo %s --create-dirs %s", jetpackfile, jetpackurl))
end

-- require("jetpack.packer").add({
--   -- manage itself
--   { "tani/vim-jetpack", opt = 1 },
--   -- utility
--   { "nvim-lua/plenary.nvim" },
--   -- startup
--   { "mhinz/vim-startify" },
--   -- preview
--   { "previm/previm" },
-- })

-- check and install
local jetpack = require("jetpack")
for _, name in ipairs(jetpack.names()) do
  if not jetpack.tap(name) then
    jetpack.sync()
    break
  end
end
