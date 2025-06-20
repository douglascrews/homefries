script_echo "MySQL setup..."

# MySQL command line prompt (https://dev.mysql.com/doc/refman/8.0/en/mysql-commands.html)
export MYSQL_PS1="\u@\h (\v) [\d]> "

#port_forward_mysql() {
#  ${ECHODO} ssh -i ~/.ssh/jumpbox.pem ec2-user@${3:-ec2-54-172-205-215.compute-1.amazonaws.com} -L ${2:-3307}:${1:-punchh-campaigns-production.czmx25rgprym.us-east-1.rds.amazonaws.com}:3306
#}

# Convenience/documentation function for MySQL connections
function mysql_connect() {
   # default params
   local default_host=localhost
   local default_port=3306
   local default_user=root
   local default_password=
   local default_database=information_schema
   local default_protocol=TCP # TCP|SOCKET|PIPE|MEMORY
   local default_comments=true

   # help
   [[ "${1}" == "--help" ]] || [[ "${1}" == "-h" ]] && { \
      help_headline ${FUNCNAME} [hostname] [port] [user] [password] [database] [protocol] [comments?]
      help_param "[host]" "Hostname to connect to" "\${MYSQL_HOST} or ${default_host}"
      help_param "[port]" "Port to connect to" "\${MYSQL_PORT} or ${default_port}"
      help_param "[user]" "User to connect as" "\${MYSQL_USER} or ${default_user}"
      help_param "[password]" "Password to connect with" "\${MYSQL_PW} or via prompt"
      help_param "[database]" "Database to connect to" "\${MYSQL_DB} or ${default_database}"
      help_param "[protocol]" "Protocol to connect with" "\${MYSQL_PROTOCOL} or ${default_protocol}"
      help_param "[comments?]" "Enable comments?" "\${MYSQL_COMMENTS} or ${default_comments}"
      help_note "*Parameters are positional" ", so if you want to specify a database, you must also specify host, port, user, password. Sue me, I'm lazy."
      help_note "!Beware, " "*mysql password parameters are passed in clear text. " "!Boo!"
      help_note "Pass '.' for any parameters to use the saved env variable value"
      return 0
   }
   
   # If no password parameter passed, mangle the command line to request it entered manually
   [[ -n "${4:-${MYSQL_PW}}" ]] && local password_equal="="

   # Save defaults for future executions
   [[ "${1}" != "." ]] && export MYSQL_HOST=${1:-${default_host}}
   [[ "${2}" != "." ]] && export MYSQL_PORT=${2:-${default_port}}
   [[ "${3}" != "." ]] && export MYSQL_USER=${3:-${default_user}}
   [[ "${4}" != "." ]] && export MYSQL_PW=${4:-${default_password}}
   [[ "${5}" != "." ]] && export MYSQL_DB=${5:-${default_database}}
   [[ "${6}" != "." ]] && export MYSQL_PROTOCOL=${6:-${default_protocol}}
   [[ "${7}" != "." ]] && export MYSQL_COMMENTS=${7:-${default_comments}}
   shift; shift; shift; shift; shift; shift; shift;

   # Beware, mysql password parameters are passed in clear text. Boo!
   ${ECHODO} mysql --host=${MYSQL_HOST} --port=${MYSQL_PORT} --user=${MYSQL_USER} --password${password_equal}${MYSQL_PW} --database=${MYSQL_DB} --protocol=${MYSQL_PROTOCOL} --tee=mysql.log --comments=${MYSQL_COMMENTS} --no-auto-rehash
}
export -f mysql_connect

# Convenience/documentation function for MySQL script execution
function mysql_run() {
   # default params
   local default_host=localhost
   local default_port=3306
   local default_user=root
   local default_password=
   local default_database=information_schema
   local default_protocol=tcp
   local default_comments=true

   # help
   [[ "${1}" == "--help" ]] || [[ "${1}" == "-h" ]] && { \
      help_headline ${FUNCNAME} '"SQL command"'
      help_headline ${FUNCNAME} 'source "scriptname"'
      help_note "You may need to define the following environment variables:"
      help_param MYSQL_HOST "Hostname to connect to" "${default_host}"
      help_param MYSQL_PORT "Port to connect to" "${default_port}"
      help_param MYSQL_USER "User to connect as" "${default_user}"
      help_param MYSQL_PW "Password to connect with" "(via prompt)"
      help_param MYSQL_DB "Database to connect to" "${default_database}"
      help_param MYSQL_PROTOCOL "Protocol to connect with" "${default_protocol}"
      help_param MYSQL_COMMENTS "Enable comments?" "${default_comments}"
      help_note "Running " "*mysql_connect" " will save these parameters for future use"
      return 0
   }
   
   # If no password parameter passed, mangle the command line to request it entered manually
   [[ -n "${MYSQL_PW}" ]] && local password_equal="="
   local -
   set -o noglob
   # The usual method of using "${ECHODO} [command] [param, ...]" does not seem to work with MySQL and the --execute param. Suboptimal.
   if [[ "${ECHODO}" == "echodo" ]]; then
      echo "mysql --host=${MYSQL_HOST:-${default_host}} --port=${MYSQL_PORT:-${default_port}} --user=${MYSQL_USER:-${default_user}} --password${password_equal}\${MYSQL_PW} --database=${MYSQL_DB:-${default_database}} --protocol=${MYSQL_PROTOCOL:-${default_protocol}} --tee=mysql.log --comments=${MYSQL_COMMENTS:-${default_comments}} --column-names --silent --table --execute=\"${*}\""
   fi
   if [[ "${ECHODO}" == "echodont" ]]; then
      echodont "mysql --host=${MYSQL_HOST:-${default_host}} --port=${MYSQL_PORT:-${default_port}} --user=${MYSQL_USER:-${default_user}} --password${password_equal}\${MYSQL_PW} --database=${MYSQL_DB:-${default_database}} --protocol=${MYSQL_PROTOCOL:-${default_protocol}} --tee=mysql.log --comments=${MYSQL_COMMENTS:-${default_comments}} --execute=\"${*}\""
   else
      mysql --host=${MYSQL_HOST:-${default_host}} --port=${MYSQL_PORT:-${default_port}} --user=${MYSQL_USER:-${default_user}} --password${password_equal}${MYSQL_PW} --database=${MYSQL_DB:-${default_database}} --protocol=${MYSQL_PROTOCOL:-${default_protocol}} --tee=mysql.log --comments=${MYSQL_COMMENTS:-${default_comments}} --column-names --silent --table --execute="${*}"
   fi
}
export -f mysql_run

function mysql_env_reset() {
   unset MYSQL_HOST
   unset MYSQL_PORT
   unset MYSQL_USER
   unset MYSQL_PW
   unset MYSQL_DB
   unset MYSQL_PROTOCOL
   unset MYSQL_COMMENTS
}
export -f mysql_env_reset

alias | grep mysql
typeset -F | grep mysql

mysql --version
