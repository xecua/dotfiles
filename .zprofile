if [ -f ~/.profile ] ; then
    emulate sh -c 'source ~/.profile'
fi

if [ -f ~/.zshrc ] ; then
    . ~/.zshrc
fi
