# start tmux
if [ -z $TMUX ] && status --is-interactive && type -q tmux
  # むしろホワイトリスト方式?
  set -l term (ps -o command= -p (string trim (ps -o ppid= -p $fish_pid)))
  if test -n "$SSH_CONNECTION" ; or test $term = 'alacritty'
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
