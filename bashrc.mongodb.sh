script_echo "MongoDB setup..."

which mongosh >/dev/null 2>&1 && alias mongo=mongosh

[[ -n "${DEBUG}" ]] && alias | grep mongo

mongosh --version
