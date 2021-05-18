set -gx GOPATH $HOME/.go

set -gx XDG_CONFIG_HOME $HOME/.config
set -gx XDG_CACHE_HOME $HOME/.cache

set -gx LANG "ja_JP.UTF-8"

set -gx HOMEBREW_EDITOR code
set -gx EDITOR nvim
set -gx NVIM_LISTEN_ADDRESS /tmp/nvim.sock

set -gx COURSIER_INSTALL_DIR ~/.local/share/coursier/bin
set -gx POETRY_HOME ~/.poetry
set -gx ANDROID_SDK_ROOT /opt/android-sdk

set -gx FZF_DEFAULT_OPTS '--reverse'

fish_add_path \
  $GOPATH/bin \
  $HOME/.cargo/bin \
  $HOME/.local/bin \
  $COURSIER_INSTALL_DIR \
  $POETRY_HOME/bin \
  $ANDROID_SDK_ROOT/cmdline-tools/latest/bin
