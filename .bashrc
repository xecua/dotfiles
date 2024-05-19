if [[ $- != *i* ]] ; then
	# Shell is non-interactive.  Be done now!
	return
fi

command -v fish >/dev/null && SHELL=$(command -v fish) exec fish

source /home/xecua/.config/broot/launcher/bash/br
