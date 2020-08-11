#!/usr/bin/env fish

# need to run exactly the root of the repository

if [ ! -d $HOME/.config ]
  mkdir $HOME/.config
end

# make symlinks
ln -s (PWD)/nvim $HOME/.config/nvim
ln -s (PWD)/fish/conf.d $HOME/.config/fish
ln -s (PWD)/git $HOME/.config/git
ln -s (PWD)/zathura $HOME/.config/zathura
ln -s (PWD)/latexmk $HOME/.config/latexmk
ln -s (PWD)/starship.toml $HOME/.config/starship.toml
ln -s (PWD)/alacritty $HOME/.config/alacritty
ln -s (PWD)/fontconfig/fonts.conf $HOME/.config/fontconfig/fonts.conf

if [ ! -d $HOME/.satysfi/local/packages ]
  mkdir -p $HOME/.satysfi/local/packages
end
ln -s (PWD)/satysfi/mylib $HOME/.satysfi/local/packages/mylib

# not to track
git update-index --assume-unchanged fish/conf.d/00-config.fish
git update-index --assume-unchanged git/config

