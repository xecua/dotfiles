if [[ -f ~/.profile ]] ; then
    . ~/.profile
fi

if [[ -f ~/.bashrc ]] ; then
    . ~/.bashrc
fi
. "/home/xecua/.local/share/cargo/env"

source /home/xecua/.config/broot/launcher/bash/br
