# .bashrc
#echo DEBUG .bashrc starting

# User specific aliases and functions

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

if [[ -r ~/.bashrc.${USER} ]]; then
	 . ~/.bashrc.${USER}
else
	[[ -n "${SSH_TTY}" ]] && echo No ~/.bashrc.${USER} found.
fi

#echo DEBUG .bashrc finished
