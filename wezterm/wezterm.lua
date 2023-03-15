local wezterm = require("wezterm")

return {
  font = wezterm.font_with_fallback({
    "UDEV Gothic 35NFLG",
    "monospace",
  }),
  color_scheme = "Molokai",
  tab_bar_at_bottom = true,
}
