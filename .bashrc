if [[ $- != *i* ]] ; then
	# Shell is non-interactive.  Be done now!
	return
fi

which fish >/dev/null && SHELL=$(which fish) exec fish
