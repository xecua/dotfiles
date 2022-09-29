local function fileformat()
  -- lualine's fileformat only shows icon *or* text
  -- when nvim-web-devicons becomes to have this, then replace with it.
  return vim.bo.fileformat .. ' ' .. vim.fn.WebDevIconsGetFileFormatSymbol()
end

require("lualine").setup({
  options = {
    theme = "wombat",
    globalstatus = true
  },
  sections = {
    lualine_b = {
      { "branch", icon = { "󿞡" }},
      { 'filename', symbols = { readonly = '[readonly]' }}},
    lualine_c = { "diagnostics" },
    lualine_x = { fileformat, "encoding", "filetype" },
    lualine_y = {},
  },
  tabline = {
    lualine_a = { { "tabs", mode = 2 }},
    lualine_y = { '" " .. os.date("%H:%M")' },
    -- on_click is supported in neovim-0.8 or higher
    -- lualine_z = {{
    --   'close',
    --   icon = {"", align = 'right'},
    --   icon_only = true,
    --   on_click = function() vim.fn.close() end
    -- }}
  },
  extensions = { 'fern', 'man', 'quickfix' }
})
