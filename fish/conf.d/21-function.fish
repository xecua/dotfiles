function randomstring
  if [ -z "$argv[1]" ]
    echo "usage: randomstring width" >&2
    return 1
end
cat /dev/urandom | base64 | fold -w $argv[1] | head -1
end

# upgrade all installed packages
function pip-upgrade
  pip install -U (pip freeze | awk -F '==' '{print $1}')
end

function pip3-upgrade
  pip3 install -U (pip3 freeze | awk -F '==' '{print $1}')
end

# https://qiita.com/mkeeda/items/c5fa878436f1cc957892
function attach_tmux_session_if_needed
  set ID (tmux list-sessions)
  if [ -z "$ID" ]
    exec tmux new-session
    return
  end

  set new_session "Create New Session"
  if type -q fzf
    set ID (string collect $ID $new_session | fzf | cut -d: -f1)
  else if type -q peco
    set ID (string collect $ID $new_session | peco --on-cancel=error | cut -d: -f1)
  else
    set ID ""
  end

  if [ "$ID" = "$new_session" ]
    exec tmux new-session
  else if [ -n "$ID" ]
    exec tmux attach-session -t "$ID"
  end
end

# mkdir and cd
function mkcd
  if [ -z "$argv[1]" ]
    echo "usage: mkcd dirname" >&2
    return 1
  end
  mkdir -p $argv[1]
  eval "cd" $argv[1]
end

function test-echo
  if [ (eval "$argv[1]") ]
    echo ok
  else
    echo ng
  end
end

# override
function fish_title
  # emacs' "term" is basically the only term that can't handle it.
  if not set -q INSIDE_EMACS; or string match -vq '*,term:*' -- $INSIDE_EMACS
    if [ (status current-command) = "fish" ]
      if [ (string match -qe '.git' (pwd)) ]
        string join '' 'fish: ' (prompt_pwd)
      elseif [ (git rev-parse --git-dir 2>/dev/null) ]
        # inside git repository
        string join '' 'fish: ' (string split '/' (git rev-parse --show-toplevel))[-1] '/' \
        (string replace -ar '(\.?[^/])[^/]*/' '$1/' (string trim -rc / (git rev-parse --show-prefix)))
      else
        string join '' 'fish: ' (prompt_pwd)
      end
    else
      status current-command
    end
  end
end
