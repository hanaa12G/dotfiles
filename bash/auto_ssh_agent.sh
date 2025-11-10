#/bin/bash

/bin/ssh-add -l &> /dev/null

if [ "$?" == 2 ]; then
    test -r $HOME/.ssh-agent && eval "$(<$HOME/.ssh-agent)" > /dev/null
    
    /bin/ssh-add -l &> /dev/null
    if [ "$?" == 2 ]; then
        (umask 066; /bin/ssh-agent > $HOME/.ssh-agent)
        eval "$(<$HOME/.ssh-agent)" > /dev/null
    fi
fi

/bin/ssh-add -l &> /dev/null

if [ "$?" == 1 ]; then
    ssh-add
fi
