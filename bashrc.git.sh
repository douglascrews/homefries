script_echo Git s[ucks]etup...

# Install Git as needed
git --version 2>/dev/null || sudo ${PACKAGE_MANAGER} -y install git

#export git_user=douglascrews
export git_user=douglascrews-partech
#export git_email=github@crewstopia.com
export git_email=douglas.crews@partech.com
export git_home=github.com

if [ ! -w ~/.gitconfig ]; then
	git config --global user.name "Douglas Crews"
	git config --global user.email "${git_email}"
	git config --global credential.helper store
	git config --global push.default simple
	git config --global core.autocrlf input
	git config --global core.excludesfile ~/.gitignore
	git config --global alias.hist 'log --pretty=format:\"%h %ad | %s%d [%an]\" --graph --date=short'
	git config --list
fi

${ECHODO} eval $(ssh-agent -s) >/dev/null 2>&1

# ssh -T git@${git_home} 2>/dev/null || (ssh-add -l 2>/dev/null | grep ${git_email} >/dev/null || (${ECHODO} eval $(ssh-agent) && ssh-add ~/.ssh/git@github.pem && ssh -T git@${git_home} >/dev/null))
#ssh -T git@${git_home} 2>/dev/null || (ssh-add -l 2>/dev/null | grep ${git_email} >/dev/null || (${ECHODO} eval $(ssh-agent) && ssh-add ~/.ssh/id_rsa && ssh -T git@${git_home} >/dev/null))
ssh -T git@${git_home} 2>/dev/null || (ssh-add -l 2>/dev/null | grep ${git_email} >/dev/null || (${ECHODO} eval $(ssh-agent) && ssh-add ~/.ssh/id_ed25519 && ssh -T git@${git_home} >/dev/null))

function git_branch_show
{
	git branch --show-current >/dev/null 2>&1 && echo "($(git branch --show-current))";
}
#export PS1="[\[${colorCyan}\]\u@\h\[${colorReset}\] \[${colorYellow}\]\W\[${colorReset}\]\$(git_branch_show)]\$ "

alias git_revert='${ECHODO} git stash save && git stash clear && ${ECHODO} git submodule init && ${ECHODO} git submodule update && ${ECHODO} git clean -f -d -x && ${ECHODO} git reset --hard && git pull && git status'
alias git_set_upstream='${ECHODO} git branch --set-upstream-to=origin/$(git symbolic-ref --short HEAD)'
