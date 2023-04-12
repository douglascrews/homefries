#######################################
# Local setup
#######################################

# Various ways to determine which distro you're running
cat /etc/*-release | grep PRETTY_NAME | cut -d '=' -f 2
lsb_release
cat /proc/version
hostnamectl

# General shortcuts
