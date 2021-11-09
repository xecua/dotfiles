#!/usr/bin/env fish
# Automatically setup script for Unix TODO?: for windows

set -l script_dir (realpath (dirname (status --current-filename)))

[ -n "$XDG_CONFIG_HOME" ]; or set XDG_CONFIG_HOME "$HOME/.config"

if not [ -d "$XDG_CONFIG_HOME" ]
  mkdir -p "$XDG_CONFIG_HOME"
end

# fish
if not [ -d "$XDG_CONFIG_HOME/fish" ]
  mkdir "$XDG_CONFIG_HOME/fish"
end
if not [ -e "$XDG_CONFIG_HOME/fish/conf.d" ]
  ln -s "$script_dir/fish/conf.d" "$XDG_CONFIG_HOME/fish/conf.d"
else
  echo "INFO: fish was not linked."
end

# shell rc
if not [ -e "$HOME/.bashrc" ]
  ln -s "$script_dir/.bashrc" "$HOME/.bashrc"
else
  echo "INFO: bashrc was not linked."
end

if not [ -e "$HOME/.bash_profile" ]
  ln -s "$script_dir/.bash_profile" "$HOME/.bash_profile"
else
  echo "INFO: bash_profile was not linked."
end

if not [ -e "$HOME/.zprofile" ]
  ln -s "$script_dir/.zprofile" "$HOME/.zprofile"
else
  echo "INFO: zprofile was not linked."
end

if not [ -e "$HOME/.zshrc" ]
  ln -s "$script_dir/.zshrc" "$HOME/.zshrc"
else
  echo "INFO: zshrc was not linked."
end

# git
if not [ -d "$XDG_CONFIG_HOME/git" ]
  mkdir "$XDG_CONFIG_HOME/git"
end

if not [ -e "$XDG_CONFIG_HOME/git/config" ]
  ln -s "$script_dir/git/config" "$XDG_CONFIG_HOME/git/config"
else
  echo "INFO: gitconfig was not linked."
end
if not [ -e "$XDG_CONFIG_HOME/git/ignore" ]
  ln -s "$script_dir/git/ignore" "$XDG_CONFIG_HOME/git/ignore"
else
  echo "INFO: gitignore was not linked."
end

# tig
if not [ -e "$XDG_CONFIG_HOME/tig" ]
  ln -s "$script_dir/tig" "$XDG_CONFIG_HOME/tig"
else
  echo "INFO: tig was not linked."
end

# picom
if not [ -d "$XDG_CONFIG_HOME/picom" ]
  ln -s "$script_dir/picom" "$XDG_CONFIG_HOME/picom"
else
  echo "INFO: picom was not linked."
end

# i3
if [ "$XDG_CURRENT_DESKTOP" = "i3" ]
  if not [ -d "$XDG_CONFIG_HOME/i3" ]
    mkdir "$XDG_CONFIG_HOME/i3"
  end
  if not [ -e "$XDG_CONFIG_HOME/i3/config" ]
    ln -s "$script_dir/i3/config" "$XDG_CONFIG_HOME/i3/config"
    # git update-index --assume-unchanged $script_dir/i3/config
  else
    echo "INFO: i3 was not linked."
  end

  if not [ -e "$XDG_CONFIG_HOME/i3/app-icons.json" ]
    ln -s "$script_dir/i3/app-icons.json" "$XDG_CONFIG_HOME/i3/config"
    # git update-index --assume-unchanged $script_dir/i3/app-icons.json
  else
    echo "INFO: i3 app-icons was not linked."
  end

  # i3blocks/config?

  ## rofi
  if not [ -e "$XDG_CONFIG_HOME/rofi" ]
    chmod +x "$script_dir/rofi/setup.sh"
    "$script_dir/rofi/setup.sh"
  else
    echo "INFO: rofi was not linked."
  end

  ## dunst
  if not [ -e "$XDG_CONFIG_HOME/dunst" ]
    ln -s "$script_dir/dunst" "$XDG_CONFIG_HOME/dunst"
  else
    echo "INFO: dunst was not linked."
  end
end

# latex: pass
# latexmk
if not [ -d "$XDG_CONFIG_HOME/latexmk" ]
  mkdir "$XDG_CONFIG_HOME/latexmk"
end

if not [ -e "$XDG_CONFIG_HOME/latexmk/latexmkrc" ]
  ln -s "$script_dir/latexmk/latexmkrc" "$XDG_CONFIG_HOME/latexmk/latexmkrc"
else
  echo "INFO: latexmk was not linked."
end

# Neovim
if not [ -e "$XDG_CONFIG_HOME/nvim" ]
  ln -s "$script_dir/nvim" "$XDG_CONFIG_HOME/nvim"
else
  echo "INFO: nvim was not linked."
end

# starship
if not [ -e "$XDG_CONFIG_HOME/starship.toml" ]
  ln -s "$script_dir/starship.toml" "$XDG_CONFIG_HOME/starship.toml"
else
  echo "INFO: starship was not linked."
end

# tmux
if not [ -e "$HOME/.tmux.conf" ]
  ln -s "$script_dir/.tmux.conf" "$HOME/.tmux.conf"
else
  echo "INFO: tmux.conf was not linked."
end

# clang-format(?)
if not [ -e "$HOME/.clang-format" ]
  ln -s "$script_dir/.clang-format" "$HOME/.clang-format"
else
  echo "INFO: clang-format was not linked."
end

# Linux(X11) specific
if [ (uname) = "Linux" ]
  # xkeysnail
  if not [ -e "$XDG_CONFIG_HOME/xkeysnail" ]
    ln -s "$script_dir/xkeysnail" "$XDG_CONFIG_HOME/xkeysnail"
  else
    echo "INFO: xkeysnail was not linked."
  end

  # fontconfig
  if not [ -e "$XDG_CONFIG_HOME/fontconfig" ]
    ln -s "$script_dir/fontconfig" "$XDG_CONFIG_HOME/fontconfig"
  else
    echo "INFO: fontconfig was not linked."
  end

  # zathura
  if not [ -e "$XDG_CONFIG_HOME/zathura" ]
    ln -s "$script_dir/zathura" "$XDG_CONFIG_HOME/zathura"
  else
    echo "INFO: zathura was not linked."
  end

  # libskk
  if not [ -d "$XDG_CONFIG_HOME/libskk" ]
    mkdir "$XDG_CONFIG_HOME/libskk"
  end
  if not [ -e "$XDG_CONFIG_HOME/libskk/rules" ]
    ln -s "$script_dir/skk/libskk/rules" "$XDG_CONFIG_HOME/libskk/rules"
  else
    echo "INFO: libskk/rules was not linked."
  end
end

# macOS specific
if [ (uname) = "Darwin" ]
  # AquaSKK (assumed to be installed)
  if [ -e "$HOME/Library/Application\ Support/AquaSKK" ]
    ln -s "$script_dir/skk/AquaSKK/*" "$HOME/Library/Application Support/AquaSKK"
  else
    echo "INFO: AquaSKK was not linked."
  end

  if not [ -e "$HOME/.Brewfile" ]
    ln -s "$script_dir/Brewfile" "$HOME/.Brewfile"
  else
    echo "INFO: Brewfile was not linked."
  end

  if not [ -d "$XDG_CONFIG_HOME/yabai" ]
    ln -s "$script_dir/yabai" "$XDG_CONFIG_HOME/yabai"
  else
    echo "INFO: yabai was not linked."
  end

  if not [ -d "$XDG_CONFIG_HOME/skhd" ]
    ln -s "$script_dir/skhd" "$XDG_CONFIG_HOME/skhd"
  else
    echo "INFO: skhd was not linked."
  end

end

# SATySFi
if not [ -d "$HOME/.satysfi/local" ]
  mkdir -p "$HOME/.satysfi/local"
end
if not [ -e "$HOME/.satysfi/local/packages" ]
  ln -s "$script_dir/satysfi/packages" "$HOME/.satysfi/local/packages"
else
  echo "INFO: satysfi was not linked."
end
