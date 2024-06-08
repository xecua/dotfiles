local wezterm = require("wezterm")
local utils = require('utils')

local config = {}
if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.font = wezterm.font_with_fallback({
  "UDEV Gothic 35NFLG",
  "monospace",
})
config.color_scheme = "Molokai"
config.tab_bar_at_bottom = true
config.native_macos_fullscreen_mode = true
config.keys = {
  { key = 'Enter', mods = 'CMD',        action = wezterm.action.ToggleFullScreen }, -- would work only for macOS
  { key = '-',     mods = 'CTRL',       action = wezterm.action.DisableDefaultAssignment },
  { key = '_',     mods = 'CTRL|SHIFT', action = wezterm.action.DisableDefaultAssignment },
  { key = '=',     mods = 'CTRL',       action = wezterm.action.DisableDefaultAssignment },
  { key = '+',     mods = 'CTRL|SHIFT', action = wezterm.action.DisableDefaultAssignment },
  { key = '0',     mods = 'CTRL',       action = wezterm.action.DisableDefaultAssignment },
}

if utils.get_os() == "Darwin" then
  config.window_decorations = "RESIZE"
  -- fullscreen on startup (on macOS)
  wezterm.on('gui-startup', function(cmd)
    local _, _, window = wezterm.mux.spawn_window(cmd or {})
    window:gui_window():toggle_fullscreen()
  end)
end


local ok, local_config = pcall(require, 'local')
if ok then
  local_config(config)
end

return config
