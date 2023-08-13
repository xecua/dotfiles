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

---@class LocalConfig
local default_local_config = {
  obsidian_dir = '~/obsidian',
  skkeleton_dictionaries = { '/usr/share/skk/SKK-JISYO.L' },
}

---@return LocalConfig
function M.get_local_config()
  local ok, config = pcall(require, 'xecua.local')
  if ok then
    return vim.tbl_extend('force', default_local_config, config)
  else
    return default_local_config
  end
end

return M
