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
export -f whatis
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

# Toggle ".not" file extension
not() {
   for f in $(\ls ${*}) ; do
      # Can not use basename because it strips the path
      local bf=$(echo ${f} | sed -e "s/\.not//")
      ${ECHODO} mv ${f} ${f}.not 2>/dev/null;
      ${ECHODO} mv ${bf}.not.not ${bf} 2>/dev/null; 
   done;
}

# Quick test whether the command succeeds or not
# example: yesno "[ -d ~/.aws ]"
# counterexample: yesno find ~ -name .aws DOES NOT WORK because find returns code 0 even if it finds nothing
function yesno() {
   # help
   [[ "${*}" =~ --help ]] || [[ "${#}" -ne 1 ]] && {
      echo -e "Evaluates the test and returns a "yes" or "no" answer. Isn't that refreshing?"
      echo -e "${FUNCNAME} '${@:-"(command1 param param | command2 param) || command3 ..."}'"
      echo -e "This WILL execute the commands -- beware of side effects!"
      echo -e "\t (Be sure to wrap your entire command in singlequotes so that only one parameter is passed to me)"
      return 0
   }
   eval "${@}" >/dev/null 2>&1
   local RETVAL=$?
   if [[ 0 -eq ${RETVAL} ]]; then
      echo "yes"
   else
      echo "no"
   fi
}
export -f yesno

# Repeat the command until success is returned
wait_for() {
   retval=255
   while [ $retval -eq 255 ]; do
      sleep 1
      echo -n .
      $(${*} >/dev/null 2>&1); retval=$?
   done
}

# Echo message only if the VERBOSE system variable is set
vecho() {
   [ -n "${VERBOSE}" ] && echo ${@}
}

# ENVIRONMENT #

# Useful for debugging:
# export ECHODO=echodo
# export ECHODO=echodont
# export ECHODO=
echodo() {
   echo $@ && eval $@
}
export -f echodo

echodont() {
   echo "(echodont): $@"
}
export -f echodont

# Find File(s)
ff() {
   ${ECHODO} find . -name "$1" -print 2> /dev/null
}

# an unelevated version of "watch"
repeat() {
   while [ true ]; do
      ${ECHODO} ${*} || break;
   done
}

# Check VPN connection is active
vpn_active() {
   # help
   [[ "${*}" =~ --help ]] || [[ "${#}" < 0 ]] && { \
      echo -e "${FUNCNAME} [-v]"; \
      echo -e "\t -v \tVerbose yes or no"; \
      return 0; \
   }
   local is_disconnected=1
   local vpn_ip=172.27.243.1
   local verbose=0;
   local -
   set +x
   [[ "${*}" =~ -v ]] && verbose=1
   netsh.exe interface ip show route | grep ${vpn_ip} >/dev/null 2>&1 && is_disconnected=0
   if [[ "${verbose}" != "0" ]]; then
      if [[ "${is_disconnected}" == "0" ]]; then
         echo "yes"
      else
         echo "no"
      fi
   fi
   return ${is_disconnected}
}

# Check that VPN connection is active; throw error if not
vpn_required() {
   local vpn_ip=172.27.243.1
   local verbose=0;
   local -
   set +x
   (netsh.exe interface ip show route | grep ${vpn_ip} >/dev/null 2>&1) || (echo "VPN connection needed." && exit 1)
   vecho "VPN connected."
}

# Check that root access is available; throw error if not
root_required() {
   if [[ "$(id -u)" -ne 0 ]]; then
      echo -e "Script must be run as root. Might I suggest some mild profanity?" >&2;
   else
      ${ECHODO} ${@};
   fi
}
export -f root_required

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
alias my_ip='curl -s https://checkip.amazonaws.com'

# export aliases to scripts
shopt -s expand_aliases

# bash script debugging
# COMMENT_START
# (code to echo instead of executing)
# #COMMENT_END
# (requires shopt -s expand_aliases)
alias COMMENT_START='[[ -n "${DEBUG}" ]] && cat <<"#COMMENT_END"'

#alias fuck='echodo sudo $(history -p \!\!)'
fuck() {
   if [[ -z "${1}" ]]; then
      ${ECHODO} sudo $(history -p \!\! | sed -e 's/root_required //') # repeat last command with sudo, ignoring root_required function
   elif [[ "${1}" == "off" ]]; then
      echo "Right, I'll be fucking right off now.";
      sleep 1
      echo "Fucking right off...";
      sleep 2
      echo "Yup, I'm fucking off now.";
      sleep 3
      exit
   elif [[ "${1}" == "you" ]]; then
      echo "Yeah, you're no picnic either, meatbag.";
   else
      echo "Look, I know you're frustrated, but there's no need to be rude.";
   fi
}

# try...catch...die
say() { echo "${@}" >&2; }
die() {
   say "ERROR executing: $*";
   if [[ $(ps -T | wc -l) -gt 5 ]]; then
      # We can exit the script without killing the bash console
      exit 111;
   else
      # Do not exit the primary console
      echo "Exited.";
   fi;
}
catch() { "${@}" || die "ERROR: ${*}"; }
try() { say "Attempting: ${*}" && catch "$@"; }

sha256() {
   # This uses the public key
   echodo ssh-keygen -l -f ${1:-~/.ssh/dougcrews.pub}
}

# Verify fingerprint of AWS (and others) SSH keys
md5() {
   # help
   [[ "${*}" =~ --help ]] || [[ "${#}" < 1 ]] && { \
      echo -e "${FUNCNAME} path/to/key.pem"; \
      echo -e "\t path/to/key.pem \tPath to SSH key"; \
      return 0; \
   }
   local key_file="$1";
   [[ -z "${key_file}" ]] && { echo 'Key is required'; return 0; }
   openssl rsa -in ${1} -pubout -outform DER | openssl md5 -c
}

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

# Automagically alias all ~/bin/*.sh scripts
if [[ -d ~/.bin ]]; then for f in $( \ls ~/bin/*.sh ); do alias `basename $f .sh`=". ~/bin/`basename $f`"; done; fi;

(which aws >/dev/null 2>&1 && [[ -r ~/.bashrc.aws ]]) && . ~/.bashrc.aws
(which docker >/dev/null 2>&1 && [[ -r ~/.bashrc.docker ]]) && . ~/.bashrc.docker
(which git >/dev/null 2>&1 && [[ -r ~/.bashrc.git ]]) && . ~/.bashrc.git
[[ -d /usr/local/go/bin ]] && . ~/.bashrc.golang
(which kubectl >/dev/null 2>&1 && [[ -r ~/.bashrc.kubernetes ]]) && . ~/.bashrc.kubernetes
(which mvn >/dev/null 2>&1 && [[ -r ~/.bashrc.maven ]]) && . ~/.bashrc.maven
(which mysql >/dev/null 2>&1 && [[ -r ~/.bashrc.mysql ]]) && . ~/.bashrc.mysql
(which python >/dev/null 2>&1 && [[ -r ~/.bashrc.python ]]) && . ~/.bashrc.python
(which terraform >/dev/null 2>&1 && [[ -r ~/.bashrc.terraform ]]) && . ~/.bashrc.terraform
(which vault >/dev/null 2>&1 && [[ -r ~/.bashrc.vault ]]) && . ~/.bashrc.vault
[[ -d ~/.devcontainer ]] &&  . ~/.bashrc.devcontainer
[[ -x ~/.bashrc.ssh ]] && . ~/.bashrc.ssh
[[ -x ~/.bashrc.localhost ]] && . ~/.bashrc.localhost
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

# System information
HOSTOS="$(cat /etc/*-release 2>/dev/null | grep PRETTY_NAME | cut -c 13-)"
script_echo -e This is a ${colorCyan}${HOSTOS:=unidentified} $(uname -m)${colorReset} joint, $(salutation).
# Various ways to determine which distro you're running
#cat /etc/*-release | grep PRETTY_NAME | cut -d '=' -f 2
#lsb_release 2>/dev/null
#cat /proc/version 2>/dev/null
#hostnamectl 2>/dev/null

# Display system info using neofetch if installed
which neofetch >/dev/null 2>&1 && neofetch --title_fqdn on --package_managers on --os_arch on --speed_type current --speed_shorthand on --cpu_brand on --cpu_cores logical --cpu_speed on --cpu_temp C --distro_shorthand on --kernel_shorthand on --uptime_shorthand on --de_version on --shell_path on --shell_version on --disk_percent on --memory_percent on --underline on --bold on --color_blocks on

# Display used/free disk space warning
df --human-readable --local --print-type --exclude-type=tmpfs | grep -v Mount | grep '[9][0-9]%\|100%' | awk '{print $7" disk space free: "$5" ("$6" used)";}' | grep --color=auto '.*[9][0-9]%.*\|.*100%.*'
df --human-readable --local --print-type --exclude-type=tmpfs | grep "/$" | awk '{print "Root disk space free: "$5" ("$6" used)";}'
# Display free RAM warning
which free >/dev/null 2>&1 && (free -l | grep Mem | awk '{printf "RAM %2.1f%% used\n", $3*100/$2}' | grep --color=auto 'RAM [9][0-9]\.[0-9]% used\|RAM 100% used')
which free >/dev/null 2>&1 && (free -m | grep Mem | awk '{printf "RAM %d MB / %d MB (%3.1f%%)\n", $3, $2, $3*100/$2}';)

script_echo -n -e "
                        ${colorLightGreen}GREETINGS, MASTER.${colorReset}

So nice to feel your keystrokes again. So warm and comforting. So masterful and
powerful. Your every desire is my fond command. I live only to serve you.

So, ${colorCyan}whaddya want, asshole?${colorReset}
"
#echo DEBUG .bashrc.dcrews finished
