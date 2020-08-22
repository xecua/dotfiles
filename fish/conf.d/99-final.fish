# start tmux
if test -z $TMUX && status --is-login
  attach_tmux_session_if_needed
end

