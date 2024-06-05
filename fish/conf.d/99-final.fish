# start tmux
if [ -z $TMUX ] && status --is-interactive && type -q tmux
  # むしろホワイトリスト方式?
  if test -n "$SSH_CONNECTION" # SSH
    or test -n "$WT_SESSION" # Windows Terminal
    or test "$TERM" = "alacritty" # Alacritty
    or test -n "$START_TMUX_ON_START" # local env
    attach_tmux_session_if_needed
  end
  # set -l ignored_terms "vscode" "iTerm.app" "Apple_Terminal"
  # if not contains $TERM_PROGRAM $ignored_terms
  #   # $TERM_PROGRAMをセットしないターミナル
  #   set -l term (ps -o command= -p (string trim (ps -o ppid= -p $fish_pid)))
  #   if not [ $term = 'tilix' ]
  #     attach_tmux_session_if_needed
  #   end
  # end
end
