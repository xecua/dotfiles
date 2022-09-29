if [[ $- != *i* ]] ; then
	# Shell is non-interactive.  Be done now!
	return
fi

command -pv fish >/dev/null && SHELL=$(command -pv fish) exec fish
