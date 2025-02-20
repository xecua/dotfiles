function cbcopy
  echo -ne "\e]52;;"
  base64 | tr -d "\n"
  echo -ne '\e\\'
end

function frg
  rm -f /tmp/rg-fzf-{r,f}
  set -f rg_command "rg --column --line-number --no-heading --color=always --smart-case "
  set -f initial_query $argv
  fzf --ansi --disabled --query "$initial_query"
  --bind "start:reload:$rg_command {q}"
  --bind "change:reload:sleep 0.1; $rg_command {q} || true"
  --bind 'ctrl-t:transform:
  [ "$FZF_PROMPT" = "2. fzf> " ] &&
  echo "rebind(change)+change-prompt(1. ripgrep> )+disable-search+transform-query:echo {q} > /tmp/rg-fzf-f; cat /tmp/rg-fzf-r" ||
  echo "unbind(change)+change-prompt(2. fzf> )+enable-search+transform-query:echo {q} > /tmp/rg-fzf-r; cat /tmp/rg-fzf-f"'
  --color "hl:-1:underline,hl+:-1:underline:reverse"
  --prompt '1. ripgrep> '
  --delimiter :
  --header 'CTRL-T: Switch between ripgrep/fzf'
  --preview 'fzf-preview.sh {1}:{2}'
  --bind 'enter:become($EDITOR {1} +{2})'
end

function fzf-git-switch -w 'git switch'
  set -f branch $argv[1]
  if [ -z "$branch" ]
    set -f branch (git branch -a | cut -c 3- | sed -E 's#^remotes/[0-9a-zA-Z_-]+/##;/^HEAD/d' | sort | uniq | fzf)
  end
  git switch $branch
end

function randomstring
  if [ -z "$argv[1]" ]
    echo "usage: randomstring width" >&2
    return 1
  end
  cat /dev/urandom | base64 | fold -w $argv[1] | head -1
end

# get user confirmation with given message or fallback message, and return 0 if y or Y given
function get-confirmation
  set -l message "$argv[1]"
  if [ -z "$argv[1]" ]
    set message "Are you sure?"
  end

  set message (string join '' $message "[y/N] ")
  read -l answer -P "$message"
  test "$answer" = "y" -o "$answer" = "Y"
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

function lscolors
  set_color -c
  for i in (seq 0 255)
    set -l color_code (printf "%03d" $i)
    printf "\e[48;5;"$i"m\e[38;5;15m "$color_code" "
    printf "\e[33;5;0m\e[38;5;"$i"m "$color_code" "
    set_color normal
    test (math $i % 8) = 7; and echo
  end
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
