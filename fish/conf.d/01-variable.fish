set -gx GOPATH $HOME/.go
set -gxp PATH $GOPATH/bin

set -gxp PATH $HOME/.cargo/bin $HOME/.local/bin

set -gx XDG_CONFIG_HOME $HOME/.config
set -gx XDG_CACHE_HOME $HOME/.cache

set -gx LANG "ja_JP.UTF-8"

set -gx NVIM_LISTEN_ADDRESS /tmp/nvim.sock

set -gx COURSIER_INSTALL_DIR ~/.local/share/coursier/bin
set -gxp PATH $COURSIER_INSTALL_DIR
