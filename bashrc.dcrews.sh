# If not running interactively, don't do anything
[[ "$-" != *i* ]] && return

#echo DEBUG .bashrc.dcrews starting

echo Setting up local environment...
#######################################
# Local setup
#######################################
#(which firewall-cmd > /dev/null 2>&1) && (sudo firewall-cmd --zone=public --add-port=8080/tcp && sudo firewall-cmd --zone=public --list-all && sudo iptables -L -n)

[[ -r ~/.bashrc.colors ]] && . ~/.bashrc.colors

# Reference implementation, overridden in .bashrc.git
function git_branch_show { 
	echo ""
}

# Enable bash completion for Maven
#which mvn >/dev/null 2>&1 && . ~/.mvn_bash_completion.sh

export PS1="[\[${colorCyan}\]\u@\h\[${colorReset}\] \[${colorYellow}\]\W\[${colorReset}\]\$(git_branch_show)]\$ "

##### Shell Functions #####

# CD #
cd_() {
   \pushd . >/dev/null && \cd -P ${1:-~}
}
alias cd=cd_
alias cd-="popd >/dev/null"

# FILES #
whatis() {
   alias ${1} 2>/dev/null || type ${1} 2>/dev/null || which ${1}
#   (alias; declare -f) | /usr/bin/which --tty-only --read-alias --read-functions --show-tilde --show-dot $@
};
#alias which=_which

# Who owns this file?
#file_owner()
#{
#   ls -l ${1} | awk '{ print $3 }'
#}
#export -f file_owner

# EDIT #

# Make a backup (once!) of the original file, and another (every time) of the current version.
#bak()
#{
#   ( \ls -a ${1}.bak >/dev/null 2>&1 && echo "Backup exists." ) || ( ls -a ${1} >/dev/null 2>&1 && sudo -u `ls -l ${1} | awk '{ print $3 }'` cp ${1} ${1}.bak && echo "Backup of ${1} created." )
#   ls -a ${1} >/dev/null 2>&1 && sudo -u `ls -l ${1} | awk '{ print $3 }'` cp ${1} .${1}.dcrews
#}
#export -f bak

# Edit file as owner with backup versions created.
#_edit()
#{
#   bak ${1}
#   sleep 1
#   sudo -u `ls -l ${1} | awk '{ print $3 }'` vi ${1}
#}
#export -f _edit
#which edit >/dev/null 2>&1 || alias edit=_edit

# Revert most recent changes.
#_revert() {
#   \ls -A ${1} >/dev/null 2>&1 && sudo -u `ls -l ${1} | awk '{ print $3 }'` mv ${1} ${1}.new && echo "Current version saved to ${1}.new.";
#   ( \ls -a .${1}.dcrews >/dev/null 2>&1 && sudo -u `ls -l .${1}.dcrews | awk '{ print $3 }'` cp .${1}.dcrews ${1} && echo "${1} reverted." ) || ( \ls -a .${1}.dcrews >/dev/null 2>&1 || echo "Cannot revert. No .${1}.dcrews found.")
#}
#export -f _revert
#which revert >/dev/null 2>&1 || alias revert=_revert

# Restore original version.
#_restore() {
#   ls -A --classify --color=tty ${1} >/dev/null 2>&1 && sudo -u `ls -l ${1} | awk '{ print $3 }'` mv ${1} ${1}.new && echo "Current version saved to ${1}.new.";
#   ( ls -a ${1}.bak >/dev/null 2>&1 && sudo -u `ls -l ${1}.bak | awk '{ print $3 }'` cp ${1}.bak ${1} && echo "${1} reverted." ) || ( ls -a ${1}.bak >/dev/null 2>&1 || echo "Cannot revert. No ${1}.bak found.")
#}
#export -f _restore
#which restore >/dev/null 2>&1 || alias restore=_restore

# ENVIRONMENT #

echodo() {
   echo $@ && eval $@
}

ff () {
   find . -name "$1" -print 2> /dev/null
}

_scp_home_to()
{
   scp -r ~/. ${USER}@${1}:~/.
}
alias scp_home_to=_scp_home_to

# DELETE/UNDELETE #

del() {
   if [[ ! -d ~/.Trash ]]; then
      echo "Setting up trashcan..."
      mkdir ~/.Trash
   fi
   temp=`\ls -d $@`;
   if [[ -n ${temp} ]]; then
     DELETED_FILES=${temp};
     DELETED_PWD=${PWD};
     echo -e "Deleting from ${colorLightPurple}${DELETED_PWD}${colorReset}: ${colorRed}${DELETED_FILES}${colorReset}";
     mv $@ ~/.Trash/.;
   else
      echo "Nothing found to delete.";
   fi
}

undelete() {
   if [[ -z ${DELETED_FILES} ]]; then
      echo "No DELETED_FILES found to undelete. Sucks to be you, huh?";
   else
      if [[ -z ${DELETED_PWD} ]]; then
         echo "No DELETED_PWD directory found to undelete into. You can''t expect me to work in these conditions, right?";
      else
         echo "Restoring files into ${DELETED_PWD}.";
         for ii in $( echo ${DELETED_FILES} ); do
            echo "Undeleting $ii...";
            mv ~/.Trash/${ii} ${DELETED_PWD}/.;
         done;
         unset DELETED_FILES;
         unset DELETED_PWD;
      fi
   fi
}

get_row() {
   awk "NR==${1:-1}"
}

get_col() {
   awk "{ print \$${1:-1} }"
}

# Install useful utilities as needed
export PACKAGE_MANAGER=$(which apt 2>/dev/null || which apt-get 2>/dev/null)$(which dnf 2>/dev/null || which yum 2>/dev/null)
# dig, nslookup, host, etc.
which nslookup >/dev/null 2>&1 || sudo ${PACKAGE_MANAGER} -y install dnsutils || sudo ${PACKAGE_MANAGER} -y install bind-utils

# General shortcuts
which apt >/dev/null 2>&1 && alias apt='sudo \apt -y'
which apt-get >/dev/null 2>&1 && alias apt-get='sudo \apt-get -y'
#alias cd=_cd__
#alias cd-=_cd--
alias cd?=dirs
alias cd..="cd .."
alias cp='\cp --preserve --interactive'
alias crontab_all='for f in `sudo ls -b /var/spool/cron` ; do echo $f ; sudo cat /var/spool/cron/$f ; done;'
alias d2u='find . -exec dos2unix {} \; && find . -name "*.bat" -exec unix2dos {} \;'
alias disk='df --human-readable --local --print-type --exclude-type=tmpfs'
which dnf 2>/dev/null && alias dnf='sudo \dnf -y'
alias flavor="cat /etc/*-release 2>/dev/null | grep PRETTY_NAME | cut -c 13-"
alias fuck='echodo sudo $(history -p \!\!)'
alias functions='typeset -F'
alias la='ls --almost-all'
alias lal='ls --almost-all -l'
alias ll='ls -l'
alias ls='ls --classify --color=tty --human-readable'
alias m=more
alias make_list='make -p 2>/dev/null | grep -A 100000 "# Files" | grep -v "^$" | grep -v "^\(\s\|#\|\.\)" | grep -v "Makefile:" | cut -d ":" -f 1 | sort -u'
alias mv='\mv --interactive'
alias ps!='ps -axfo pid,uname,%cpu,%mem,cmd'
alias popd='\popd >/dev/null'
alias pushd='\pushd >/dev/null'
which free >/dev/null 2>&1 && alias ram='free -m | grep Mem | awk "{printf \"%d MB / \%d MB (\%3.1f%\%)\n\", \$3, \$2, \$3*100/\$2}" 2>/dev/null'
alias rm='\rm --interactive'
alias script_echo='[[ -n "${SSH_TTY:-$(tty)}" ]] && echo' # only echo if in interactive session
alias shit='echodo $(history -p \!\!) | less'
alias watch_that='echodo watch --beep --differences --interval 1 $(history -p \!\!)'
which yum 2>/dev/null && alias yum='sudo \yum -y'

# Enable Terraform cli tab autocomplete
(which terraform > /dev/null 2>&1) && complete -C /usr/bin/terraform terraform

# Automagically alias all ~/bin/*.sh scripts
if [[ -d ~/.bin ]]; then for f in $( \ls ~/bin/*.sh ); do alias `basename $f .sh`=". ~/bin/`basename $f`"; done; fi;

(which docker >/dev/null 2>&1 && [[ -r ~/.bashrc.docker ]]) && . ~/.bashrc.docker
(which git >/dev/null 2>&1 && [[ -r ~/.bashrc.git ]]) && . ~/.bashrc.git
(which kubectl >/dev/null 2>&1 && [[ -r ~/.bashrc.kubernetes ]]) && . ~/.bashrc.kubernetes
(which mvn >/dev/null 2>&1 && [[ -r ~/.bashrc.maven ]]) && . ~/.bashrc.maven
(which python >/dev/null 2>&1 && [[ -r ~/.bashrc.python ]]) && . ~/.bashrc.python
(which vault >/dev/null 2>&1 && [[ -r ~/.bashrc.vault ]]) && . ~/.bashrc.vault
[[ -d ~/.devcontainer ]] &&  . ~/.bashrc.devcontainer
[[ -x ~/.bashrc.${HOSTNAME} ]] && . ~/.bashrc.${HOSTNAME}
#echo DEBUG Finished calling sub-bashrc files

salutation() {
   #local r=$(( 1+( $(od -An -N1 -i /dev/random) )%(5) ));
   local r=$(( 1+(RANDOM*5/32767) ))
   if [[ $r -eq 1 ]]; then
      echo -e "${colorRed}asshole${colorReset}";
   fi;
   if [[ $r -eq 2 ]]; then
      echo -e "${colorPurple}dear${colorReset}";
   fi;
   if [[ $r -eq 3 ]]; then
      echo -e "${colorYellow}honey${colorReset}";
   fi;
   if [[ $r -eq 4 ]]; then
      echo -e "${colorCyan}sweetie${colorReset}";
   fi;
   if [[ $r -eq 5 ]]; then
      echo -e "${colorDarkGray}jerkface${colorReset}";
   fi;
}
export -f salutation

# Other options include  $(lsb_release -d 2>/dev/null | cut -f 2) $(cat /proc/version 2>/dev/null)
HOSTOS="$(cat /etc/*-release 2>/dev/null | grep PRETTY_NAME | cut -c 13-)"
script_echo -e This is a ${colorCyan}${HOSTOS:=unidentified} `uname -m`${colorReset} joint, `salutation`.

# Display used/free disk space warning
df --human-readable --local --print-type --exclude-type=tmpfs | grep -v Mount | grep '[9][0-9]%\|100%' | awk '{print $7" disk space free: "$5" ("$6" used)";}' | grep --color=auto '.*[9][0-9]%.*\|.*100%.*'
df --human-readable --local --print-type --exclude-type=tmpfs | grep "/$" | awk '{print "Root disk space free: "$5" ("$6" used)";}'
# Display free RAM warning
which free >/dev/null 2>&1 && (free -l | grep Mem | awk '{printf "RAM %2.1f%% used\n", $3*100/$2}' | grep --color=auto 'RAM [9][0-9]\.[0-9]% used\|RAM 100% used')
which free >/dev/null 2>&1 && (free -m | grep Mem | awk '{printf "RAM %d MB / %d MB (%3.1f%%)\n", $3, $2, $3*100/$2}';)

[[ -r ~/.bashrc.${HOSTNAME} ]] && . ~/.bashrc.${HOSTNAME}

script_echo -n -e "
                        ${colorLightGreen}GREETINGS, MASTER.${colorReset}

So nice to feel your keystrokes again. So warm and comforting. So masterful and
powerful. Your every desire is my fond command. I live only to serve you.

So, ${colorCyan}whaddya want, asshole?${colorReset}
"
#echo DEBUG .bashrc.dcrews finished
