-- lua_post_source {{{
local function fileformat()
  -- lualine's fileformat only shows icon *or* text
  -- when nvim-web-devicons becomes to have this, then replace with it.
  return vim.bo.fileformat .. ' ' .. vim.fn.WebDevIconsGetFileFormatSymbol()
end

local function shiftwidth()
  -- インデントがタブかどうか、タブ幅はどうか(expandtabとtabstopしかいじらないようにしてるのでその2つで判別可能)
  local indentation = vim.o.expandtab and 'Space' or 'Tab'
  local width = vim.o.tabstop
  return indentation .. ':' .. width
end

local function ddu()
  if vim.o.ft:find('^ddu') == nil then
    return ''
  end

  local status = vim.w.ddu_ui_ff_status -- { name = "default", input = "aaa", done = true, maxItems = 30 }

  return string.format('[%s-%s] %d/%d', vim.o.ft, status.name, vim.fn.line('$'), status.maxItems)
end

require('lualine').setup({
  options = {
    theme = 'wombat',
    globalstatus = true,
    disabled_filetypes = {
      winbar = { 'dap-repl' },
    },
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = {
      { 'branch', icon = { '' } }, -- 0xe702 (devicons)
    },
    lualine_c = {
      -- arkav/lualine-lsp-progress
      ddu,
      'lsp_progress',
      'diagnostics',
    },
    lualine_x = {},
    lualine_y = { fileformat, shiftwidth, 'encoding', 'filetype' },
    lualine_z = { 'location' },
  },
  tabline = {
    lualine_a = {
      {
        'tabs',
        max_length = function()
          return vim.o.columns * 2 / 3
        end,
        mode = 2,
      },
    },
    lualine_b = {
      {
        -- 'create new tabpage' component
        '""', -- 0xf067 (Font Awesome)
        on_click = function(args)
          vim.cmd('tabnew')
        end,
      },
    },
    lualine_y = { '" " .. os.date("%H:%M")' },
  },
  winbar = {
    lualine_b = { { 'filename', path = 1, symbols = { readonly = '[readonly]' } } },
    lualine_c = { { 'navic', navic_opts = { lazy_update_context = true } } },
    lualine_z = {
      {
        '""', -- 0xf00d (Font Awesome)
        on_click = function()
          vim.api.nvim_win_close(0, false)
        end,
      },
    },
  },
  inactive_winbar = {
    -- dduとかではdisableにしたい
    lualine_b = { { 'filename', path = 1, symbols = { readonly = '[readonly]' } } },
    -- lualine_c = { "navic" },
    -- lualine_z = {
    --   {
    --     '""', -- 0xf00d (Font Awesome)
    --     on_click = function()
    --       local winnum = *ここが必要*
    --       vim.api.nvim_win_close(winnum, false)
    --     end,
    --   },
    -- },
  },
  extensions = { 'fern', 'man', 'quickfix', 'trouble', 'nvim-dap-ui', 'fugitive', 'symbols-outline' },
})
-- }}}
