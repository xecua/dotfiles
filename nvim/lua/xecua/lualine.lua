local function breadcrumb()
  local navic = require("nvim-navic")
  if navic.is_available() then
    return navic.get_location()
  else
    return ""
  end
end

local function fileformat()
  -- lualine's fileformat only shows icon *or* text
  -- when nvim-web-devicons becomes to have this, then replace with it.
  return vim.bo.fileformat .. " " .. vim.fn.WebDevIconsGetFileFormatSymbol()
end

local function shiftwidth()
  -- インデントがタブかどうか、タブ幅はどうか(expandtabとtabstopしかいじらないようにしてるのでその2つで判別可能)
  local indentation = vim.o.expandtab and "Space" or "Tab"
  local width = vim.o.tabstop
  return indentation .. ":" .. width
end

require("lualine").setup({
  options = {
    theme = "wombat",
    globalstatus = true,
  },
  sections = {
    lualine_b = {
      { "branch", icon = { "" } }, -- 0xe702 (devicons)
      { "filename", path = 1, symbols = { readonly = "[readonly]" } },
    },
    lualine_c = {
      breadcrumb,
      -- arkav/lualine-lsp-progress
      "lsp_progress",
      "diagnostics",
    },
    lualine_x = {
      -- codota/tabnine-nvim
      "tabnine",
    },
    lualine_y = { fileformat, shiftwidth, "encoding", "filetype" },
  },
  tabline = {
    lualine_a = {
      {
        "tabs",
        max_length = vim.o.columns * 2 / 3,
        mode = 2,
      },
    },
    lualine_b = {
      {
        -- 'create new tabpage' component
        '""', -- 0xf067 (Font Awesome)
        on_click = function()
          vim.cmd("tabnew")
        end,
      },
    },
    lualine_y = { '" " .. os.date("%H:%M")' },
    lualine_z = {
      {
        -- 'close current buffer' component
        '""', -- 0xf00d (Font Awesome)
        cond = function()
          return vim.fn.tabpagenr("$") ~= 1
        end,
        on_click = function()
          vim.cmd("close")
        end,
      },
    },
  },
  inactive_winbar = {
    lualine_c = { "filename" },
  },
  extensions = { "fern", "man", "quickfix", "trouble", "nvim-dap-ui", "fugitive", "symbols-outline" },
})
