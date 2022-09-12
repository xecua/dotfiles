-- Neovim uses LuaJIT 2.1, which is compatible with Lua 5.1 (does not implement unicode escape(\u{}))
vim.g.lightline = {
  colorscheme = "wombat",
  tabline = {
    left = { { "tabs" } },
    right = { { "close" }, { "time" } },
  },

  separator = { left = "", right = "" }, -- \u{e0b0}, \u{e0b2}

  subseparator = { left = "", right = "" }, -- \u{e0b1}, \u{e0b3}
  active = {
    left = { { "mode", "paste" }, { "gitbranch", "readonly", "filename" } },
    right = { { "lineinfo" }, { "fileformat", "fileencoding", "filetype" } },
  },
  inactive = { left = { { "filename" } }, right = { { "lineinfo" } } },
  component_function = {
    time = 'LightLineTime',
    readonly = "LightLineReadOnly",
    mode = "LightLineMode",
    filetype = "LightLineFiletype",
    fileformat = "LightLineFileFormat",
    fileencoding = "LightLineFileencoding",
    gitbranch = "LightLineGitBranch",
  },
}

local filer = "ddu-filer"

local function is_exceptional_filetype()
  local filetype = vim.opt.filetype:get()
  return filetype == 'help' or filetype == filer
end

function LightLineTime()
  -- return vim.fn.strftime('%H:%M')
  return os.date('%H:%M')
end

function LightLineGitBranch()
  if is_exceptional_filetype() then
    return ""
  end
  local head = vim.fn.FugitiveHead()
  if string.len(head) == 0 then
    return ""
  end
  return "󿞡" .. head -- \u{ff7a1}
end

function LightLineFilename()
  local filetype = vim.opt.ft:get()
  if filetype == "denite" then
    return vim.fn["denite#get_status"]("sources")
  elseif is_exceptional_filetype() then
    return ""
  else
    local filename = vim.fn.expand("%")
    if string.len(filename) == 0 then
      return "[No Name]"
    else
      return filename
    end
  end
end

function LightLineReadOnly()
  if not is_exceptional_filetype() and vim.opt.readonly:get() then
    return "[readonly]"
  else
    return ""
  end
end

function LightLineMode()
  local filetype = vim.opt.ft:get()
  if filetype == 'denite' then
    return 'Denite'
  elseif vim.api.nvim_win_get_width(0) > 70 then
    return vim.fn['lightline#mode']()
  else
    return ''
  end
end

function LightLineFiletype()
  local filetype = vim.opt.ft:get()
  if is_exceptional_filetype() or vim.api.nvim_win_get_width(0) < 70 then
    return ''
  elseif filetype ~= '' then
    return filetype .. ' ' .. vim.fn.WebDevIconsGetFileTypeSymbol()
  else
    return 'no ft'
  end
end

function LightLineFileFormat()
  if vim.api.nvim_win_get_width(0) < 70 then
    return ''
  else
    return vim.opt.fileformat:get() .. ' ' .. vim.fn.WebDevIconsGetFileFormatSymbol()
  end
end

function LightLineFileencoding()
  if vim.api.nvim_win_get_width(0) < 70 then
    return ''
  else
    local fileencoding = vim.opt.fenc:get()
    if fileencoding ~= '' then
      return fileencoding
    else
      return vim.opt.enc:get()
    end
  end
end

vim.cmd[[
  function! LightLineTime() abort
    return v:lua.LightLineTime()
  endfunction

  function! LightLineGitBranch() abort
    return v:lua.LightLineGitBranch()
  endfunction

  function! LightLineFilename() abort
    return v:lua.LightLineFilename()
  endfunction

  function! LightLineReadOnly() abort
    return v:lua.LightLineReadOnly()
  endfunction

  function! LightLineMode() abort
    return v:lua.LightLineMode()
  endfunction

  function! LightLineFiletype() abort
    return v:lua.LightLineFiletype()
  endfunction

  function! LightLineFileFormat() abort
    return v:lua.LightLineFileFormat()
  endfunction

  function! LightLineFileencoding() abort
    return v:lua.LightLineFileencoding()
  endfunction

]]
