local function fileformat()
  -- lualine's fileformat only shows icon *or* text
  -- when nvim-web-devicons becomes to have this, then replace with it.
  return vim.bo.fileformat .. " " .. vim.fn.WebDevIconsGetFileFormatSymbol()
end

require("lualine").setup({
  options = {
    theme = "wombat",
    globalstatus = true,
  },
  sections = {
    lualine_b = {
      { "branch", icon = { "󿞡" } },
      { "filename", symbols = { readonly = "[readonly]" } },
    },
    lualine_c = { "diagnostics" },
    lualine_x = { fileformat, "encoding", "filetype" },
    lualine_y = {},
  },
  tabline = {
    lualine_a = { { "tabs", mode = 2 } },
    lualine_b = {
      {
        '""', -- 'create new tabpage' component
        on_click = function()
          vim.cmd("tabnew")
        end,
      },
    },
    lualine_y = { '" " .. os.date("%H:%M")' },
    lualine_z = {
      {
        '""', -- 'close current buffer' component
        cond = function()
          return vim.fn.tabpagenr("$") ~= 1
        end,
        on_click = function()
          vim.cmd("close")
        end,
      },
    },
  },
  extensions = { "fern", "man", "quickfix" },
})
