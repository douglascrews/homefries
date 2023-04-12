
# DCREWS CUSTOM
if [[ -r ~/.bashrc.${USER} ]]; then
	 . ~/.bashrc.${USER}
else
	[[ -n "${SSH_TTY}" ]] && echo No ~/.bashrc.${USER} found.
fi
