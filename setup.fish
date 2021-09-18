#!/usr/bin/env fish
# Automatically setup script for Unix
# TODO?: for windows

set -l script_dir (realpath (dirname (status --current-filename)))

[ -n "$XDG_CONFIG_HOME" ]; or set XDG_CONFIG_HOME "$HOME/.config"

if not [ -d $XDG_CONFIG_HOME ]
  mkdir -p $XDG_CONFIG_HOME
end

# fish
if not [ -d $XDG_CONFIG_HOME/fish ]
  mkdir $XDG_CONFIG_HOME/fish
end

# override
if not [ -e $HOME/.bashrc ]
  mv $script_dir/.bashrc $HOME
end
if not [ -e $HOME/.bash_profile ]
  mv $script_dir/.bash_profile $HOME
end

## if exist, do nothing
if not [ -e $XDG_CONFIG_HOME/fish/conf.d ]
  ln -s $script_dir/fish/conf.d $XDG_CONFIG_HOME/fish/conf.d
end

# git
if not [ -d $XDG_CONFIG_HOME/git ]
  mkdir $XDG_CONFIG_HOME/git
end

if not [ -e $XDG_CONFIG_HOME/git/config ]
  ln -s $script_dir/git/config $XDG_CONFIG_HOME/git/config
end
if not [ -e $XDG_CONFIG_HOME/git/ignore ]
  ln -s $script_dir/git/ignore $XDG_CONFIG_HOME/git/ignore
end

# tig
if not [ -e $XDG_CONFIG_HOME/tig ]
  ln -s $sciprt_dir/tig $XDG_CONFIG_HOME/tig
end

# picom
if not [ -d $XDG_CONFIG_HOME/picom ]
  ln -s $script_dir/picom $XDG_CONFIG_HOME/picom
end

# i3
if [ $XDG_CURRENT_DESKTOP = "i3" ]
  if not [ -d $XDG_CONFIG_HOME/i3 ]
    mkdir $XDG_CONFIG_HOME/i3
  end
  if not [ -e $XDG_CONFIG_HOME/i3/config ]
    ln -s $script_dir/i3/config $XDG_CONFIG_HOME/i3/config
    # git update-index --assume-unchanged $script_dir/i3/config
  end

  if not [ -e $XDG_CONFIG_HOME/i3/app-icons.json ]
    ln -s $script_dir/i3/app-icons.json $XDG_CONFIG_HOME/i3/config
    # git update-index --assume-unchanged $script_dir/i3/app-icons.json
  end

  # i3blocks/config?

  ## rofi
  if not [ -e $XDG_CONFIG_HOME/rofi ]
    ln -s $script_dir/rofi $XDG_CONFIG_HOME/rofi
  end

  ## dunst
  if not [ -e $XDG_CONFIG_HOME/dunst ]
    ln -s $script_dir/dunst $XDG_CONFIG_HOME/dunst
  end
end

# latex: pass
# latexmk
if not [ -d $XDG_CONFIG_HOME/latexmk ]
  mkdir $XDG_CONFIG_HOME/latexmk
end

if not [ -e $XDG_CONFIG_HOME/latexmk/latexmkrc ]
  ln -s $script_dir/latexmk/latexmkrc $XDG_CONFIG_HOME/latexmk/latexmkrc
end

# Neovim
if not [ -e $XDG_CONFIG_HOME/nvim ]
  ln -s $script_dir/nvim $XDG_CONFIG_HOME/nvim
end

# starship
if not [ -e $XDG_CONFIG_HOME/starship.toml ]
  ln -s $script_dir/starship.toml $XDG_CONFIG_HOME/starship.toml
end

# tmux
if not [ -e $HOME/.tmux.conf ]
  ln -s $script_dir/.tmux.conf $HOME/.tmux.conf
end

# clang-format(?)
if not [ -e $HOME/.clang-format ]
  ln -s $sciprt_dir/.clang-format $HOME/.clang-format
end

# Linux(X11) specific
if [ (uname) = "Linux" ]
  # xkeysnail
  if not [ -e $XDG_CONFIG_HOME/xkeysnail ]
    ln -s $sciprt_dir/xkeysnail $XDG_CONFIG_HOME/xkeysnail
  end
  # fontconfig
  if not [ -e $XDG_CONFIG_HOME/fontconfig ]
    ln -s $sciprt_dir/fontconfig $XDG_CONFIG_HOME/fontconfig
  end
  # zathura
  if not [ -e $XDG_CONFIG_HOME/zathura ]
    ln -s $sciprt_dir/zathura $XDG_CONFIG_HOME/zathura
  end
  # libskk
  if not [ -d $XDG_CONFIG_HOME/libskk ]
    mkdir $XDG_CONFIG_HOME/libskk
  end
  if not [ -e $XDG_CONFIG_HOME/libskk/rules ]
    ln -s $script_dir/skk/libskk/rules $XDG_CONFIG_HOME/libskk/rules
  end
end

# macOS specific
if [ (uname) == "Darwin" ]
  # AquaSKK (assumed to be installed)
  if [ -e $HOME/Library/Application\ Support/AquaSKK ]
    ln -s $script_dir/skk/AquaSKK/* $HOME/Library/Application\ Support/AquaSKK
  end

  ln -s $script_dir/Brewfile $HOME/.Brewfile

end

# SATySFi
if not [ -d $HOME/.satysfi/local ]
  mkdir -p $HOME/.satysfi/local
end
if not [ -e $HOME/.satysfi/local/packages ]
  ln -s $sciprt_dir/satysfi/packages $HOME/.satysfi/local/packages
end
