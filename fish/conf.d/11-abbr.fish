abbr --add g git
abbr --add gti git
abbr --add gitop 'cd (git rev-parse --show-toplevel)'

function open_vim
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
abbr --add vi --function open_vim
abbr --add vim --function open_vim
abbr --add nvim --function open_vim
abbr --add nvimdiff --function 'nvim -d'
abbr --add :q exit

function lastcmd
  echo $history[1]
end
abbr --add !! --function lastcmd

function multidot
  echo (string repeat -n (math (string length -- $argv[1]) - 1) '../')
end
abbr --add dotdot --position anywhere --regex '^\.\.+$' --function multidot

# conditions
if [ (uname) = 'Darwin' ]
  abbr --add sudoedit sudo -e
end

if type -q emerge
  set -l emerge_update 'sudo emerge -avtuDU --keep-going --autounmask=n % @world'
  abbr --add udon --set-cursor $emerge_update
  abbr --add うどん --set-cursor $emerge_update
end

# POSIX overrides
if type -q exa
  set -l exa_command 'exa --header --git --time-style=iso --modified --created'
  abbr --add l   "$exa_command"
  abbr --add ls  "$exa_command --icons"
  abbr --add ll  "$exa_command --icons --long"
  abbr --add la  "$exa_command --icons --long --all"
  abbr --add lt  "$exa_command --icons --tree --git-ignore"
  abbr --add llt "$exa_command --icons --tree --long"
  abbr --add lat "$exa_command --icons --tree --long --all"
else
  abbr --add l 'ls -CF'
  abbr --add ll 'ls -alF'
  abbr --add la 'ls -A'
end
abbr --add sl ls

if type -q htop
  abbr --add top htop
end

if type -q batman
  abbr --add man batman
end
