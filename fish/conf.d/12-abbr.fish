# dynamic, modification-prone commands and textual correction
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

if type -q emerge
  set -l emerge_update 'sudo emerge -avtuDU --keep-going --autounmask=n % @world'
  abbr --add udon --set-cursor $emerge_update
  abbr --add うどん --set-cursor $emerge_update
end
