local M = require("lualine.component"):extend()
local check = require("xecua.skkeleton").should_use_skkeleton

function M:init(options)
  M.super.init(self, options)
end

function M:update_status(is_focused)
  if not check() then
    return ""
  end
  local mode = vim.fn["skkeleton#mode"]()
  local stats = {
    [""] = "a",
    hira = "あ",
    kata = "ア",
    hankata = "ｱ",
    zenkaku = "Ａ",
    abbrev = "abbrev",
  }

  return "SKK: " .. stats[mode]
end

-- 色付け
-- function M:adjust_hl()
-- end

return M
