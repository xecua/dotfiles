# dynamic, modification-prone commands and textual correction

bind -M insert \cg expand-abbr

function expand_vim
  if type -q nvim
    echo nvim
  else if type -q vim
    echo vim
  else if type -q vi
    echo vi
  else
    return 1
  end
end

abbr --add nvim --function expand_vim
abbr --add vim --function expand_vim
abbr --add vi --function expand_vim

function fzf_vim
  set -f vim_command (expand_vim)
  set -f target (fzf --preview 'fzf-preview.sh {}')
  if [ -z $target ]
    return 1
  end
  echo $vim_command $target
end
abbr --add fv --function fzf_vim

function fzf_cat
  if type -q bat
    set -f cat_command bat
  else
    set -f cat_command cat
  end
  set -f target (fzf --preview 'fzf-preview.sh {}')
  if [ -z $target ]
    return 1
  end
  echo $cat_command $target
end
abbr --add fc --function fzf_cat

abbr --add g git
abbr --add gti git

abbr --add sl ls

function lastcmd
  echo $history[1]
end
abbr --add !! --function lastcmd

function multidot
  echo (string repeat -n (math (string length -- $argv[1]) - 1) '../')
end
abbr --add dotdot --position anywhere --regex '^\.\.+$' --function multidot

function expand_neovide
  if type -q neovide.exe
    echo neovide.exe --wsl
  else
    echo neovide
  end
end
abbr --add nv --function expand_neovide


if type -q emerge
  set -l emerge_update 'sudo emerge -avtuDU --keep-going --with-bdeps=y --autounmask=n% @world'
  abbr --add udon --set-cursor $emerge_update
  abbr --add うどん --set-cursor $emerge_update

  abbr --add ec --set-cursor 'bat (equery w %)'
end
