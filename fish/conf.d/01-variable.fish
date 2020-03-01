# oh-my-fish/theme-bobthefish
set -g theme_display_date no
set -g theme_display_cmd_duration no

set -gx XDG_CONFIG_HOME $HOME/.config
set -gx XDG_CACHE_HOME $HOME/.cache
set -gx XDG_RUNTIME_DIR $HOME/.tmp
set -gx LANG "ja_JP.UTF-8"
set -gx LC_ALL "$LANG"

set -gxp PATH $HOME/.cargo/bin $HOME/.wasmtime/bin $HOME/go/bin
set -gxa PATH /usr/local/bin /usr/local/sbin
