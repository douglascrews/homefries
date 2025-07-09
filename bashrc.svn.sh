script_echo "Subversion setup..."

alias svn_autocommit='svn commit --message "$(svn diff | grep -e "+++" -e "---")"'

alias | grep svn
