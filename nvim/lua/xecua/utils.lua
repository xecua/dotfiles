local M = {}

function M.normalize_punctuation()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, true)
  local new_lines = {}
  for i, line in ipairs(lines) do
    new_lines[i] = vim.fn.substitute(vim.fn.substitute(line, '、', '，', 'ge'), '。', '．', 'ge')
  end
  vim.api.nvim_buf_set_lines(0, 0, -1, true, new_lines)
end

local os_string = nil
function M.get_os_string()
  if os_string == nil then
    if vim.fn.has('win64') == 1 or vim.fn.has('win32') == 1 or vim.fn.has('win16') == 1 then
      os_string = 'Windows'
    else
      os_string = vim.fn.system('uname'):gsub('\n', '')
      if os_string == 'Linux' and string.find(vim.fn.readfile('/proc/version')[1], 'microsoft') ~= nil then
        os_string = 'WSL'
      end
    end
  end
  return os_string
end

---@return { obsidian_dir: string, skkeleton_dictionaries: array<string> }
function M.get_local_config()
  local dein = require('dein')
  local skkdict_path = dein.get('dict').path
  local emoji_jisyo_path = dein.get('skk-emoji-jisyo').path

  local skkeleton_dictionaries = {
    skkdict_path .. '/SKK-JISYO.L',
    skkdict_path .. '/SKK-JISYO.jinmei',
    skkdict_path .. '/SKK-JISYO.geo',
    skkdict_path .. '/SKK-JISYO.station',
    skkdict_path .. '/SKK-JISYO.propernoun',
    skkdict_path .. '/SKK-JISYO.itaiji',
    skkdict_path .. '/SKK-JISYO.itaiji.JIS3_4',
    skkdict_path .. '/SKK-JISYO.JIS2004',
    skkdict_path .. '/SKK-JISYO.JIS2',
    skkdict_path .. '/SKK-JISYO.JIS3_4',
    emoji_jisyo_path .. '/SKK-JISYO.emoji.utf8',
  }

  local ok, config = pcall(require, 'xecua.local')
  if ok then
    vim.list_extend(skkeleton_dictionaries, config.skkeleton_directories or {})

    return {
      obidian_dir = config.obsidian_dir,
      skkeleton_dictionaries = skkeleton_dictionaries,
    }
  else
    return {
      skkeleton_dictionaries = skkeleton_dictionaries,
    }
  end
end

return M
