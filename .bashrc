# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history, nor lines starting with a space
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend
# git-like `**` path expansion
shopt -s globstar
# don't try to complete empty lines
shopt -s no_empty_cmd_completion
# `echo` expands backslash-escape sequences by default
shopt -s xpg_echo
# update the values of LINES and COLUMNS after each command
shopt -s checkwinsize
# if a command name is the name of a directory, cd into it
shopt -s autocd

# This option is used to map ^W, and even if you bind another action
# on ^W in your .inputrc, it always take precedence, so you have
# to explicitely undefine it.
stty werase undef

# history length (very large for stats)
HISTSIZE=600
HISTFILESIZE=30000

# make less more friendly for non-text input files
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

[ -f ~/.private_bashrc ] && . ~/.private_bashrc;

# enable color support of ls/grep/…
DIRCOLOR=
[ -x /usr/bin/dircolors ] ||
    [[ $(tput -T$TERM colors) -ge 8 ]] && DIRCOLOR='--color=auto'

if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

function _bash_prompt_command {

    local NEWPWD=$PWD
    local l=30
    local GITPROMPT=' '
    local TMP=
    local GITBR=
    local ROOTPROMPT=

    [ $EUID -eq 0 ] && ROOTPROMPT='[#]'

    local GITSTATUS=$(git status 2> /dev/null)

    if [ $? -eq 0 ]; then
        echo $GITSTATUS | grep 'not staged' &> /dev/null
        if [ $? -eq 0 ]; then
            if [ $DIRCOLOR ]; then
                GITPROMPT="\[\033[1;31m\]+\[\033[0m\]"
            else
                GITPROMPT='+'
            fi
        fi

        GITBR=$(git describe --contains --all HEAD 2> /dev/null)

        if [ $? -eq 0 ]; then
            if [ $DIRCOLOR ]; then
                GITPROMPT=" \033[0;36m{$GITBR}\[\033[0m\]$GITPROMPT";
            else
                GITPROMPT=" {$GITBR}$GITPROMPT";
            fi
        fi

    fi

    # Replace "/home/foo" with "~"
    NEWPWD=${PWD//$HOME/\~}

    # get current path, with only the first letter of the parent directoy, e.g.:
    #
    #  /home/alice/foo -> a/foo
    #
    NEWPWD=$(echo $NEWPWD | perl -pe 's%.*/(.)[^/]*(?=/)%\1%')
    
    if [ $DIRCOLOR ]; then
        # colors
        PS1="\h:${NEWPWD}${ROOTPROMPT}${GITPROMPT}\[\033[1;33m\]%\[\033[0m\] "
    else
        # no colors
        PS1="\h:${NEWPWD}${ROOTPROMPT}${GITPROMPT}% "
    fi
}

case $TERM in
    xterm*|rxvt*|aterm|kterm|gnome*)
        _bash_prompt_command;
        PROMPT_COMMAND='_bash_prompt_command';;
    *)
        ;;
esac

# need <C-d> twice to quit
ignoreeof=1

# variables
export EDITOR='vim'
export PS2='… '
export PATH="$PATH:/usr/local/sbin:$HOME/bin"

# == Programming ==

alias vim='vim -p'

# Node
export NODE_PATH='/usr/lib/node_modules'

# OCaml
alias locaml='ledit ocaml'

# Python
alias python='python3'
export PYTHONSTARTUP=~/.pythonrc.py

# R
export R_HOME='/usr/lib/R'

# usual
alias ps='ps x'
alias top='htop'
alias cd='cd -P'
alias du='du -h'
alias df='df -h'

alias -- -='cd -'
alias +x='chmod u+x'

alias  grep="grep $DIRCOLOR"
alias fgrep="fgrep $DIRCOLOR"
alias egrep="egrep $DIRCOLOR"

alias la='ls -a'
alias lr='ls -R'

function mkcd { mkdir -p "$1" && cd "$1"; }

alias reload='source ~/.bashrc'

# one-letter shortcuts
alias c=cd
alias g=git
alias m=mv
alias n=node
alias s=sudo
alias v=vim

# two-letters ones
alias ct=cat
alias f~='find . -name "*~" -delete'
alias fn='find . -name'
alias mk=make

# Personal scripts
for f in $HOME/bin/functions/*.sh; do [ -x $f ] && . $f; done

# Internet
alias pker='ping -c 1 -w 1 kernel.org'

if [ "`uname`" = "Darwin" ] && [ -f "$HOME/.bashrc_osx" ]; then
    . $HOME/.bashrc_osx
elif [[ "`uname`" =~ "Ubuntu" ]] && [ -f "$HOME/.bashrc_ubuntu" ]; then
    . $HOME/.bashrc_ubuntu
fi
