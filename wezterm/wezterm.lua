local wezterm = require('wezterm')
local utils = require('utils')

wezterm.GLOBAL.os = wezterm.target_triple:find('linux') ~= nil and 'Linux'
  or wezterm.target_triple:find('darwin') ~= nil and 'Darwin'
  or wezterm.target_triple:find('windows') ~= nil and 'Windows'
  or 'Unknown'
wezterm.GLOBAL.user = os.getenv('USER') or os.getenv('LOGNAME') or os.getenv('USERNAME')
wezterm.GLOBAL.home = os.getenv('HOME') or os.getenv('USERPROFILE')

local config = {}
if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.font = wezterm.font_with_fallback({
  'UDEV Gothic 35NFLG',
  'monospace',
})
config.color_scheme = 'Molokai'
config.tab_bar_at_bottom = true
config.scrollback_lines = 8192
config.native_macos_fullscreen_mode = true
config.macos_forward_to_ime_modifier_mask = 'SHIFT|CTRL'
config.status_update_interval = 10 * 1000
config.keys = {
  { key = 'Enter', mods = 'CMD', action = wezterm.action.ToggleFullScreen }, -- would work only for macOS
  { key = '-', mods = 'CTRL', action = wezterm.action.DisableDefaultAssignment },
  { key = '_', mods = 'CTRL|SHIFT', action = wezterm.action.DisableDefaultAssignment },
  { key = '=', mods = 'CTRL', action = wezterm.action.DisableDefaultAssignment },
  { key = '+', mods = 'CTRL|SHIFT', action = wezterm.action.DisableDefaultAssignment },
  { key = '0', mods = 'CTRL', action = wezterm.action.DisableDefaultAssignment },
}

if wezterm.GLOBAL.os == 'Darwin' then
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

  if pane:get_domain_name() ~= 'local' then
    text = text .. icon('md_cloud') .. wezterm.GLOBAL.user .. '@' .. pane:get_domain_name()
  end

  local cwd = pane:get_current_working_dir()
  if cwd ~= nil then
    text = text .. icon('md_folder') .. string.gsub(cwd.file_path, '^' .. wezterm.GLOBAL.home, '~')
  end

  local _, w, _ = wezterm.run_child_process({ 'w' })
  text = text .. icon('md_speedometer') .. string.gsub(w:match('load averages?: ([0-9,. ]+)'), ',', '')

  local batteries = ''
  for _, b in ipairs(wezterm.battery_info()) do
    local bi = ''
    if b.state == 'Charing' then
      bi = b.state_of_charge < 0.1 and icon('md_battery_charging_outline')
        or icon('md_battery_charging_' .. (math.floor(b.state_of_charge * 10) * 10))
    elseif b.state ~= 'Unkown' then
      bi = b.state_of_charge == 1 and icon('md_battery')
        or b.state_of_charge < 0.1 and icon('md_battery_outline')
        or icon('md_battery_' .. (math.floor(b.state_of_charge * 10) * 10))
    end

    if bi ~= '' then
      batteries = batteries .. bi .. string.format('%.0f%%', b.state_of_charge * 100)
    end
  end
  text = text .. batteries

  text = text .. icon('md_calendar') .. wezterm.strftime('%Y-%m-%d (%a)')
  text = text .. icon('md_clock') .. wezterm.strftime('%H:%M:%S')

  window:set_right_status(wezterm.format({ { Text = text .. '　' } }))
end)

local ok, local_config = pcall(require, 'local')
if ok then
  local_config(config)
end

return config
