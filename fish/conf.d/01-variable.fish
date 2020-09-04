set -gx GOPATH $HOME/.go
set -gxp PATH $GOPATH/bin

set -gx XDG_CONFIG_HOME $HOME/.config
set -gx XDG_CACHE_HOME $HOME/.cache
set -gx XDG_RUNTIME_DIR $HOME/.tmp
set -gx LANG "ja_JP.UTF-8"

set -gx NVIM_LISTEN_ADDRESS /tmp/nvim.sock


