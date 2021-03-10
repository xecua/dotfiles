# start tmux
if test -z $TMUX && status --is-interactive && type -q tmux
  attach_tmux_session_if_needed
end
