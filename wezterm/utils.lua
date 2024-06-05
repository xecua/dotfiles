local M = {}
local wezterm = require('wezterm')

function M.get_os()
  if wezterm.target_triple:find("linux") ~= nil then
    return "Linux"
  elseif wezterm.target_triple:find("darwin") ~= nil then
    return "Darwin"
  elseif wezterm.target_triple:find("windows") ~= nil then
    return "Windows"
  end
end

return M
