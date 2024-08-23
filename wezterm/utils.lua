local M = {}
local wezterm = require('wezterm')

function M.split(s, sep)
  local fields = {}
  sep = sep or ' '
  local pattern = string.format('([^%s]+)', sep)
  string.gsub(s, pattern, function(c)
    fields[#fields + 1] = c
  end)

  return fields
end

function M.join(t, sep)
  local s = ''
  sep = sep or ' '
  for i, v in ipairs(t) do
    s = s .. v .. (i == #t and '' or sep)
  end
  return s
end

return M
