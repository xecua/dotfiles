set -gx GOPATH $HOME/.go
set -gxp PATH $GOPATH/bin

set -gxp PATH $HOME/.cargo/bin $HOME/.yarn/bin $HOME/.npm/bin $HOME/.local/bin

set -gx XDG_CONFIG_HOME $HOME/.config
set -gx XDG_CACHE_HOME $HOME/.cache

set -gx LANG "ja_JP.UTF-8"

set -gx NVIM_LISTEN_ADDRESS /tmp/nvim.sock

set -gx RIPGREP_CONFIG_PATH $HOME/.config/ripgrep/config

