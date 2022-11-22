#!/usr/bin/env fish
# Automatically setup script for Unix TODO?: for windows

set -l script_dir (realpath (dirname (status --current-filename)))

[ -n "$XDG_CONFIG_HOME" ]; or set XDG_CONFIG_HOME "$HOME/.config"
[ -n "$XDG_CACHE_HOME" ]; or set XDG_CACHE_HOME "$HOME/.cache"
[ -n "$XDG_DATA_HOME" ]; or set XDG_DATA_HOME "$HOME/.local/share"

mkdir -p "$XDG_CONFIG_HOME"

# fish
mkdir -p "$XDG_CONFIG_HOME/fish"
if not [ -e "$XDG_CONFIG_HOME/fish/conf.d" ]
  ln -s "$script_dir/fish/conf.d" "$XDG_CONFIG_HOME/fish/conf.d"
else
  echo "WARN: fish was not linked."
end

# shell rc
if not [ -e "$HOME/.profile" ]
  ln -s "$script_dir/.profile" "$HOME/.profile"
  echo "INFO: profile linked."
else
  echo "WARN: profile was not linked."
end

if not [ -e "$HOME/.bashrc" ]
  ln -s "$script_dir/.bashrc" "$HOME/.bashrc"
  echo "INFO: bashrc linked."
else
  echo "WARN: bashrc was not linked."
end

if not [ -e "$HOME/.bash_profile" ]
  ln -s "$script_dir/.bash_profile" "$HOME/.bash_profile"
  echo "INFO: bash_profile linked."
else
  echo "WARN: bash_profile was not linked."
end

if not [ -e "$HOME/.zprofile" ]
  ln -s "$script_dir/.zprofile" "$HOME/.zprofile"
  echo "INFO: zprofile linked."
else
  echo "WARN: zprofile was not linked."
end

if not [ -e "$HOME/.zshrc" ]
  ln -s "$script_dir/.zshrc" "$HOME/.zshrc"
  echo "INFO: zshrc linked."
else
  echo "WARN: zshrc was not linked."
end

# git
mkdir -p "$XDG_CONFIG_HOME/git"
if not [ -e "$XDG_CONFIG_HOME/git/config" ]
  ln -s "$script_dir/git/config" "$XDG_CONFIG_HOME/git/config"
  echo "INFO: gitconfig linked."
else
  echo "WARN: gitconfig was not linked."
end
if not [ -e "$XDG_CONFIG_HOME/git/ignore" ]
  ln -s "$script_dir/git/ignore" "$XDG_CONFIG_HOME/git/ignore"
  echo "INFO: gitignore linked."
else
  echo "WARN: gitignore was not linked."
end

# tig
if not [ -e "$XDG_CONFIG_HOME/tig" ]
  ln -s "$script_dir/tig" "$XDG_CONFIG_HOME/tig"
  echo "INFO: tig linked."
else
  echo "WARN: tig was not linked."
end
mkdir -p "$XDG_DATA_HOME/tig"

# picom
if not [ -d "$XDG_CONFIG_HOME/picom" ]
  ln -s "$script_dir/picom" "$XDG_CONFIG_HOME/picom"
  echo "INFO: picom linked."
else
  echo "WARN: picom was not linked."
end

# SSR
mkdir -p "$XDG_CONFIG_HOME/simplescreenrecorder"

# wget
if not [ -e "$XDG_CONFIG_HOME/wgetrc" ]
  echo "hsts-file = \"$XDG_CACHE_HOME\"wget-hsts" >"$XDG_CONFIG_HOME/wgetrc"
  echo "INFO: wget configured."
else
  echo "WARN: wget was not configured."
end

# i3
if [ "$XDG_CURRENT_DESKTOP" = "i3" ]
  if not [ -d "$XDG_CONFIG_HOME/i3" ]
    ln -s "$script_dir/i3" "$XDG_CONFIG_HOME/i3"
    echo "INFO: i3 linked."
  else
    echo "WARN: i3 was not linked."
  end

  # i3blocks?
  if not [ -e "$XDG_CONFIG_HOME/i3status-rust" ]
    ln -s "$script_dir/i3status-rust" "$XDG_CONFIG_HOME/i3status-rust"
    echo "INFO: i3status-rust linked."
  else
    echo "WARN: i3status-rust was not linked."
  end

  ## rofi
  if not [ -e "$XDG_CONFIG_HOME/rofi" ]
    chmod +x "$script_dir/rofi/setup.sh"
    "$script_dir/rofi/setup.sh"
    echo "INFO: rofi linked."
  else
    echo "WARN: rofi was not linked."
  end

  ## dunst
  if not [ -e "$XDG_CONFIG_HOME/dunst" ]
    ln -s "$script_dir/dunst" "$XDG_CONFIG_HOME/dunst"
    echo "INFO: dunst linked."
  else
    echo "WARN: dunst was not linked."
  end
end

# latex: pass
# latexmk
mkdir -p "$XDG_CONFIG_HOME/latexmk"
if not [ -e "$XDG_CONFIG_HOME/latexmk/latexmkrc" ]
  ln -s "$script_dir/latexmk/latexmkrc" "$XDG_CONFIG_HOME/latexmk/latexmkrc"
  echo "INFO: latexmk linked."
else
  echo "WARN: latexmk was not linked."
end

# latexindent: setting up .indentconfig.yaml
if not [ -e "$HOME/.indentconfig.yaml" ]
  echo "\
paths:
  - $script_dir/latexindent/setting.yaml
" > "$HOME/.indentconfig.yaml"
  echo "INFO: indentconfig.yaml created."
else
  echo "WARN: indentconfig.yaml was not created."
end

# npm / yarn
if command -v npm >/dev/null
  npm config set prefix "$XDG_DATA_HOME/npm"
  npm config set cache "$XDG_CACHE_HOME/npm"
  npm config set init-module "$XDG_CONFIG_HOME/npm/config/npm-init.js"
  echo "INFO: npm configured."
else
  echo "WARN: npm was not configured. Never forget to set manually."
end

if command -v yarn >/dev/null
  yarn config set prefix "$XDG_DATA_HOME/yarn"
  echo "INFO: yarn prefix is set."
else
  echo "WARN: yarn was not configured. Never forget to set manually."
end

# Neovim
if not [ -e "$XDG_CONFIG_HOME/nvim" ]
  ln -s "$script_dir/nvim" "$XDG_CONFIG_HOME/nvim"
  echo "INFO: nvim linked."
else
  echo "WARN: nvim was not linked."
end

# ideavim
if not [ -e "$XDG_CONFIG_HOME/ideavim" ]
  ln -s "$script_dir/ideavim" "$XDG_CONFIG_HOME/ideavim"
  echo "INFO: ideavim linked."
else
  echo "WARN: ideavim was not linked."
end

# alacritty
mkdir -p "$XDG_CONFIG_HOME/alacritty"
if not [ -e "$XDG_CONFIG_HOME/alacritty/alacritty.yml" ]
  ln -s "$script_dir/alacritty/alacritty.yml" "$XDG_CONFIG_HOME/alacritty/alacritty.yml"
else
  echo "WARN: alacritty was not linked."
end
if not [ -e "$HOME/.alacritty.yml.local" ]
  # platform specific, imported by above file
  touch "$HOME/.alacritty.yml.local"
end

# starship
if not [ -e "$XDG_CONFIG_HOME/starship.toml" ]
  ln -s "$script_dir/starship.toml" "$XDG_CONFIG_HOME/starship.toml"
  echo "INFO: starship linked."
else
  echo "WARN: starship was not linked."
end

# tmux
mkdir -p "$XDG_CONFIG_HOME/tmux"
if not [ -e "$XDG_CONFIG_HOME/tmux/tmux.conf" ]
  ln -s "$script_dir/tmux/tmux.conf" "$XDG_CONFIG_HOME/tmux/tmux.conf"
  echo "INFO: tmux linked."
else
  echo "WARN: tmux.conf was not linked."
end

# ranger
mkdir -p "$XDG_CONFIG_HOME/ranger"
if not [ -e "$XDG_CONFIG_HOME/ranger/rc.conf" ]
  ln -s "$script_dir/ranger/rc.conf" "$XDG_CONFIG_HOME/ranger/rc.conf"
  echo "INFO: ranger/rc.conf linked."
else
  echo "WARN: ranger/rc.conf was not linked."
end
if not [ -e "$XDG_CONFIG_HOME/ranger/rifle.conf" ]
  ln -s "$script_dir/ranger/rifle.conf" "$XDG_CONFIG_HOME/ranger/rifle.conf"
  echo "INFO: ranger/rifle.conf linked."
else
  echo "WARN: ranger/rifle.conf was not linked."
end

# clang-format(?)
if not [ -e "$HOME/.clang-format" ]
  ln -s "$script_dir/.clang-format" "$HOME/.clang-format"
  echo "INFO: clang-format linked."
else
  echo "WARN: clang-format was not linked."
end

# Linux(X11) specific
if [ (uname) = "Linux" ]
  # xkeysnail
  if not [ -e "$XDG_CONFIG_HOME/xkeysnail" ]
    ln -s "$script_dir/xkeysnail" "$XDG_CONFIG_HOME/xkeysnail"
    echo "INFO: xkeysnail linked."
  else
    echo "WARN: xkeysnail was not linked."
  end

  # fontconfig
  if not [ -e "$XDG_CONFIG_HOME/fontconfig" ]
    ln -s "$script_dir/fontconfig" "$XDG_CONFIG_HOME/fontconfig"
    echo "INFO: fontconfig linked."
  else
    echo "WARN: fontconfig was not linked."
  end

  # zathura
  if not [ -e "$XDG_CONFIG_HOME/zathura" ]
    ln -s "$script_dir/zathura" "$XDG_CONFIG_HOME/zathura"
    echo "INFO: zathura linked."
  else
    echo "WARN: zathura was not linked."
  end

  # libskk
  mkdir -p "$XDG_CONFIG_HOME/libskk"
  if not [ -e "$XDG_CONFIG_HOME/libskk/rules" ]
    ln -s "$script_dir/skk/libskk/rules" "$XDG_CONFIG_HOME/libskk/rules"
  else
    echo "WARN: libskk/rules was not linked."
  end
end

# macOS specific
if [ (uname) = "Darwin" ]
  # AquaSKK (assumed to be installed)
  if [ -e "$HOME/Library/Application\ Support/AquaSKK" ]
    ln -s "$script_dir/skk/AquaSKK/*" "$HOME/Library/Application Support/AquaSKK"
    echo "INFO: AquaSKK linked."
  else
    echo "WARN: AquaSKK was not linked."
  end

  if not [ -e "$HOME/.Brewfile" ]
    ln -s "$script_dir/Brewfile" "$HOME/.Brewfile"
    echo "INFO: Brewfile linked."
  else
    echo "WARN: Brewfile was not linked."
  end

  if not [ -d "$XDG_CONFIG_HOME/yabai" ]
    ln -s "$script_dir/yabai" "$XDG_CONFIG_HOME/yabai"
    echo "INFO: yabai linked."
  else
    echo "WARN: yabai was not linked."
  end

  if not [ -d "$XDG_CONFIG_HOME/skhd" ]
    ln -s "$script_dir/skhd" "$XDG_CONFIG_HOME/skhd"
    echo "INFO: shkd linked."
  else
    echo "WARN: skhd was not linked."
  end

end

# SATySFi
mkdir -p "$HOME/.satysfi/local"
if not [ -e "$HOME/.satysfi/local/packages" ]
  ln -s "$script_dir/satysfi/packages" "$HOME/.satysfi/local/packages"
  echo "INFO: satysfi linked."
else
  echo "WARN: satysfi was not linked."
end
