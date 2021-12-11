if status --is-interactive
  # typo
  if type -q git
    alias gti git
    alias g git
  end

  if type -q exa
    if [ (uname) = 'Linux' ]
      # --created is not supported on Linux? https://github.com/ogham/exa/issues/576
      set exa_command 'exa --header --git --time-style=iso --modified'
    else
      set exa_command 'exa --header --git --time-style=iso --modified --created'
    end
    alias l   "$exa_command"
    alias ls  "$exa_command --icons"
    alias ll  "$exa_command --icons --long"
    alias la  "$exa_command --icons --long --all"
    alias lt  "$exa_command --icons --tree --git-ignore"
    alias llt "$exa_command --icons --tree --long"
    alias lat "$exa_command --icons --tree --long --all"
  else
    alias ll 'ls -alF'
    alias la 'ls -A'
    alias l 'ls -CF'
  end
  alias sl ls

  if type -q rg
    alias rg 'rg --smart-case'
  end

  if type -q nvim
    alias vi nvim
    alias vim nvim
  else
    alias vi vim
  end
  alias :q exit

  if type -q htop
    alias top htop
  end

  if type -q batman
    alias man batman
  end

  if type -q ssh-agent
    # in fish, ssh-agent must be used with -c
    alias ssh-agent 'ssh-agent -c'
  end

  if [ (uname) = 'Darwin' ]
    alias sudoedit 'sudo -e'
  end

  if type -q emerge
    alias うどん 'sudo emerge -auvDN --with-bdeps=y --keep-going @world'
  end
end
