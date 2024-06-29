-- lua_add {{{
vim.g.submode_timeout = false
vim.g.submode_always_show_submode = true
-- }}}

-- lua_post_source {{{
local function nmap_enter(mode, key)
  vim.fn['submode#enter_with'](mode, 'n', '', key, key)
end

local function nmap(mode, lhs, rhs)
  vim.fn['submode#map'](mode, 'n', '', lhs, rhs)
end

-- horizontal scroll
local scroll_mode_key = 'Scroll'
nmap_enter(scroll_mode_key, 'zh')
nmap_enter(scroll_mode_key, 'zl')
nmap_enter(scroll_mode_key, 'zH')
nmap_enter(scroll_mode_key, 'zL')
nmap(scroll_mode_key, 'h', 'zh')
nmap(scroll_mode_key, 'l', 'zl')
nmap(scroll_mode_key, 'H', 'zH')
nmap(scroll_mode_key, 'L', 'zL')

-- resize
local resize_mode_key = 'Resize'
nmap_enter(resize_mode_key, '<C-w>+')
nmap_enter(resize_mode_key, '<C-w>-')
nmap_enter(resize_mode_key, '<C-w><')
nmap_enter(resize_mode_key, '<C-w>>')
nmap(resize_mode_key, '+', '<C-w>+')
nmap(resize_mode_key, '-', '<C-w>-')
nmap(resize_mode_key, '<', '<C-w><')
nmap(resize_mode_key, '>', '<C-w>>')
-- }}}
