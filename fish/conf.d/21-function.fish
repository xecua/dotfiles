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
    if test -z "$ID"
        exec tmux new-session
        return
    end

    set new_session "Create New Session" 
    set ID (echo $ID\n$new_session | peco --on-cancel=error | cut -d: -f1)
    if test "$ID" = "$new_session"
        exec tmux new-session
    else if test -n "$ID"
        exec tmux attach-session -t "$ID"
    end
end

