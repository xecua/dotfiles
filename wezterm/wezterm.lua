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
config.scrollback_lines = 8192
config.native_macos_fullscreen_mode = true
config.macos_forward_to_ime_modifier_mask = 'SHIFT|CTRL'
config.status_update_interval = 10 * 1000
config.keys = {
  { key = 'Enter', mods = 'CMD',        action = wezterm.action.ToggleFullScreen }, -- would work only for macOS
  { key = '-',     mods = 'CTRL',       action = wezterm.action.DisableDefaultAssignment },
  { key = '_',     mods = 'CTRL|SHIFT', action = wezterm.action.DisableDefaultAssignment },
  { key = '=',     mods = 'CTRL',       action = wezterm.action.DisableDefaultAssignment },
  { key = '+',     mods = 'CTRL|SHIFT', action = wezterm.action.DisableDefaultAssignment },
  { key = '0',     mods = 'CTRL',       action = wezterm.action.DisableDefaultAssignment },
}

if utils.get_os() == "Darwin" then
  -- fullscreen on startup (on macOS)
  wezterm.on('gui-startup', function(cmd)
    local _, _, window = wezterm.mux.spawn_window(cmd or {})
    window:gui_window():toggle_fullscreen()
  end)
end

local function icon(name)
  return '　' .. wezterm.nerdfonts[name] .. '　'
end

wezterm.on('update-right-status', function(window, pane)
  local text = ''

  local _, w, _ = wezterm.run_child_process({ 'w' })
  text = text .. icon('md_speedometer') .. string.gsub(w:match('load averages?: ([0-9,. ]+)'), ',', '')

  local batteries = ''
  for _, b in ipairs(wezterm.battery_info()) do
    local bi = b.state == 'Full' and icon('md_battery_full')
        or b.state == 'Charging' and icon('md_battery_charging')
        or b.state == 'Empty' and icon('md_battery_outline')
        or b.state == 'Discharging' and icon('md_battery' .. (math.floor(b.state_of_charge * 10) * 10))
        or ''
    if bi ~= '' then
      batteries = batteries .. bi .. string.format('%.0f%%', b.state_of_charge * 100)
    end
  end
  text = text .. batteries

  text = text .. icon('md_calendar') .. wezterm.strftime('%Y-%m-%d (%W)')
  text = text .. icon('md_clock') .. wezterm.strftime('%H:%M:%S')

  window:set_right_status(
    wezterm.format({ { Text = text .. '　' } })
  )
end)

local ok, local_config = pcall(require, 'local')
if ok then
  local_config(config)
end

return config
