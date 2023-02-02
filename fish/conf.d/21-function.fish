function randomstring
  if [ -z "$argv[1]" ]
    echo "usage: randomstring width" >&2
    return 1
  end
  cat /dev/urandom | base64 | fold -w $argv[1] | head -1
end

function go-update
  # https://zenn.dev/kyoh86/articles/291618538dcf0d
  pushd $HOME
  set gobin (go env GOBIN)
  if [ -z "$gobin" ]
    set gobin (go env GOPATH)/bin
  end

  for ex in $(find $gobin -type f -executable)
    set -l pkg (go version -m $ex | head -2 | tail -1 | awk '{print $2}')
    go install "$pkg@latest"
  end
  popd
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

# switch `delta` option when teminal size changed (https://github.com/dandavison/delta/issues/359#issuecomment-799628302)
function __delta-switch-flag --on-signal WINCH
  if [ "$COLUMNS" -ge 120 ]; and not contains "side-by-side" "$DELTA_FEATURES"
    set -gxp DELTA_FEATURES "side-by-side"
  else if [ "$COLUMNS" -lt 120 ]
    set -l i (contains --index "side-by-side" "$DELTA_FEATURES")
    if [ -n "$i" ]
      set -e DELTA_FEATURES[$i]
    end
  end
end
__delta-switch-flag # on created

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

#https://fishshell.com/docs/current/relnotes.html#fish-3-6-0-released-january-7-2023; alias ... -> ../../
function multicd
  echo cd (string repeat -n (math (string length -- $argv[1]) - 1) ../)
end

abbr --add dotdot --regex '^\.\.+$' --function multicd
