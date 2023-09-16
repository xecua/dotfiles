# dynamic, modification-prone commands and textual correction

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

function broot_vim
  set -l vim_command (expand_vim)
  set -l broot_result (brf)
  if [ -z $broot_result ]
    return 1
  end
  echo $vim_command $broot_result
end
abbr --add brv --function broot_vim

function broot_cat
  set -l cat_command ''
  if type -q bat
    set cat_command bat
  else
    set cat_command cat
  end
  set -l broot_result (brf)
  if [ -z $broot_result ]
    return 1
  end
  echo $cat_command $broot_result
end
abbr --add brc --function broot_cat

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
  set -l emerge_update 'sudo emerge -avtuDU --keep-going --autounmask=n% @world'
  abbr --add udon --set-cursor $emerge_update
  abbr --add うどん --set-cursor $emerge_update
end
