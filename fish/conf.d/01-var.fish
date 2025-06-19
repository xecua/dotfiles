# enable vi mode (fish_vi_key_bindings sets universal variable)
# https://github.com/microsoft/vscode/issues/248719
if not [ "$TERM_PROGRAM" = "vscode" ]
  set -g fish_key_bindings fish_vi_key_bindings
end
