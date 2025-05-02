script_echo "MySQL setup..."

# MySQL command line prompt (https://dev.mysql.com/doc/refman/8.0/en/mysql-commands.html)
export MYSQL_PS1="\u@\h (\v) [\d]> "

#port_forward_mysql() {
#  ${ECHODO} ssh -i ~/.ssh/jumpbox.pem ec2-user@${3:-ec2-54-172-205-215.compute-1.amazonaws.com} -L ${2:-3307}:${1:-punchh-campaigns-production.czmx25rgprym.us-east-1.rds.amazonaws.com}:3306
#}

# Convenience/documentation function for MySQL connections
mysql_connect() {
   # default params
   local default_host=localhost
   local default_port=3306
   local default_user=admin
   local default_password=
   local default_database=information_schema
   local default_protocol=tcp
   local default_comments=true

   # help
   [[ "${1}" == "--help" ]] || [[ "${1}" == "-h" ]] && { \
      echo -e "\
${FUNCNAME}() [hostname] [port] [user] [password] [database] [protocol] [comments?]\n \
\t [host] Hostname to connect to (default \${MYSQL_HOST} or ${default_host})\n \
\t [port] Port to connect to (default \${MYSQL_PORT} or ${default_port})\n \
\t [user] User to connect as (default \${MYSQL_USER} or ${default_user})\n \
\t [password] Password to connect with (default \${MYSQL_PW} or via prompt)\n \
\t [database] Database to connect to (default \${MYSQL_DB} or ${default_database})\n \
\t [protocol] Protocol to connect with (default \${MYSQL_PROTOCOL} or ${default_protocol})\n \
\t [comments?] Enable comments? (default \${MYSQL_COMMENTS} or ${default_comments})\n \
Parameters are numbered, so if you want to specify a database, you must also specify host, port, user, password. Sue me, I'm lazy. \
"; \
      return 0; \
   }
   
   # If no password parameter passed, mangle the command line to request it entered manually
   [[ -n "${4:-${MYSQL_PW}}" ]] && local password_equal="="
   # Parameters are locational; order matters
   # Beware, mysql password parameters are passed in clear text. Boo!
   ${ECHODO} mysql --host=${1:-${MYSQL_HOST:-${default_host}}} --port=${2:-${MYSQL_PORT:-${default_port}}} --user=${3:-${MYSQL_USER:-${default_user}}} --password${password_equal}${4:-${MYSQL_PW}} --database=${5:-${MYSQL_DB:-${default_database}}} --protocol=${6:-${MYSQL_PROTOCOL:-${default_protocol}}} --tee=mysql.log --comments=${7:-${MYSQL_COMMENTS:-${default_comments}}} --no-auto-rehash
}
export -f mysql_connect

# Convenience/documentation function for MySQL script execution
mysql_run() {
   # default params
   local default_host=localhost
   local default_port=3306
   local default_user=admin
   local default_password=
   local default_database=punchh_production
   local default_protocol=tcp
   local default_comments=true

   # help
   [[ "${1}" == "--help" ]] || [[ "${1}" == "-h" ]] && { \
      echo -e " \
${FUNCNAME}() \"[SQL command]\" or \"source [scriptname]\"\n \
\t You may need to define the following environment variables:\n \
\t MYSQL_HOST (default ${MYSQL_HOST:-${default_host}})\n \
\t MYSQL_PORT (default ${MYSQL_PORT:-${default_port}})\n \
\t MYSQL_USER (default ${MYSQL_USER:-${default_user}})\n \
\t MYSQL_PW (via prompt)\n \
\t MYSQL_DB (default ${MYSQL_DB:-${default_database}})\n \
\t MYSQL_PROTOCOL (default ${MYSQL_PROTOCOL:-${default_protocol}})\n \
\t MYSQL_COMMENTS (default ${MYSQL_COMMENTS:-${default_comments}}) \
"; \
      return 0; \
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

mysql --version
