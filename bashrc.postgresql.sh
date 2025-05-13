script_echo "PostgreSQL setup..."

# Install
#sudo apt-get install -y postgresql postgresql-contrib

# Start PostgreSQL client locally as superuser
#su - postgres
#psql

# Convenience/documentation function for PostgreSQL connection
function psql_connect() {
   # default params
   local default_host=localhost
   local default_port=5432
   local default_user=postgres
   local default_password=postgres
   local default_database=information_schema

   # help
   [[ "${1}" == "--help" ]] || [[ "${1}" == "-h" ]] && {
      help_headline ${FUNCNAME} [hostname] [port] [user] [password] [database]
      help_param '[host]' 'Hostname to connect to' "\${PSQL_HOST} or ${default_host}"
      help_param '[port]' 'Port to connect to' "\${PSQL_PORT} or ${default_port}"
      help_param '[user]' 'User to connect as' "\${PSQL_USER} or ${default_user}"
      help_param '[password]' 'Password to connect with' "\${PSQL_PW} or \${PGPASSWORD}"
      help_param '[database]' 'Database to connect to' "\${PSQL_DB} or ${default_database}"
      help_note "Parameters are positional, so if you want to specify a database, you must also specify host, port, user, password. Sue me, I'm lazy."
      return 0
   }
   
   # Parameters are positional; order matters
   PGPASSWORD=${4:-${PSQL_PW}} ${ECHODO} psql --host=${1:-${PSQL_HOST:-${default_host}}} --port=${2:-${PSQL_PORT:-${default_port}}} --username=${3:-${PSQL_USER:-${default_user}}} --dbname=${5:-${PSQL_DB:-${default_database}}}
}
export -f psql_connect

# Convenience/documentation function for PostgreSQL script execution
function psql_run() {
   # default params
   local default_host=localhost
   local default_port=5432
   local default_user=postgres
   local default_password=postgres
   local default_database=information_schema

   # help
   [[ "${1}" == "--help" ]] || [[ "${1}" == "-h" ]] && {
      help_headline ${FUNCNAME} [SQL command]
      help_note "You may need to define the following environment variables:"
      help_param PSQL_HOST "\${PSQL_HOST} (${PSQL_HOST})" ${default_host}
      help_param PSQL_PORT "\${PSQL_PORT} (${PSQL_PORT})" ${default_port}
      help_param PSQL_USER "\${PSQL_USER} (${PSQL_USER})" ${default_user}
      help_param PSQL_PW "\t\${PSQL_PW} (\${PGPASSWORD})" $(([[ -n "${PGPASSWORD}" ]] && echo "(set)") || echo "(not set)")
      help_param PSQL_DB "\t\${PSQL_DB} (${PSQL_DB})" ${default_database}
      return 0;
   }
   
   set -o noglob # Do not expand the SQL command parameter into separate params, pass it as a string
   PGPASSWORD=${4:-${PSQL_PW}} ${ECHODO} psql --host=${PSQL_HOST:-${default_host}} --port=${PSQL_PORT:-${default_port}} --username=${PSQL_USER:-${default_user}} --dbname=${PSQL_DB:-${default_database}} --dbname=${PSQL_DB:-${default_database}} --command="${*}"
}
export -f psql_run

# Convenience/documentation function for PostgreSQL connection test; returns 0 on success, nonzero on failure
function psql_test() {
   # default params
   local default_host=localhost
   local default_port=5432
   local default_user=postgres
   local default_password=postgres
   local default_database=information_schema
   local default_wait_seconds=10

   # help
   [[ "${1}" == "--help" ]] || [[ "${1}" == "-h" ]] && { \
      help_headline ${FUNCNAME} [hostname] [port] [user] [password] [database] [wait_seconds]
      help_param "[host]" "Hostname to connect to" "\${PSQL_HOST} or ${default_host}"
      help_param "[port]" "Port to connect to" "\${PSQL_PORT} or ${default_port}"
      help_param "[user]" "User to connect as" "\${PSQL_USER} or ${default_user}"
      help_param "[password]" "Password to connect with" "\${PSQL_PW} or \${PGPASSWORD}"
      help_param "[database]" "Database to connect to" "\${PSQL_DB} or ${default_database}"
      help_param "[wait_seconds]" "Seconds to wait for connection" "\${PSQL_WAITSEC} or ${default_wait_seconds}"
      help_note "Parameters are positional, so if you want to specify a database, you must also specify host, port, user, password. Sue me, I'm lazy."
      return 0; \
   }

   # Parameters are positional; order matters
   PSQL_HOST=${1:-${PSQL_HOST:-${default_host}}}
   PSQL_PORT=${2:-${PSQL_PORT:-${default_port}}}
   PSQL_USER=${3:-${PSQL_USER:-${default_user}}}
   PSQL_PW=${4:-${PSQL_PW:-${default_password}}}
   PSQL_DB=${5:-${PSQL_DB:-${default_database}}}
   PSQL_WAITSEC=${6:-${PSQL_WAITSEC:-${default_wait_seconds}}}
   PGPASSWORD=${PSQL_PW} ${ECHODO} pg_isready --host=${PSQL_HOST} --port=${PSQL_PORT} --username=${PSQL_USER} --dbname=${PSQL_DB} --timeout=${PSQL_WAITSEC} || echo -e "${colorRed}psql connection failed.${colorReset}"
   # Fallback is pg_isready is not found
   #PGPASSWORD=${4:-${PSQL_PW}} ${ECHODO} psql --host=${1:-${PSQL_HOST:-${default_host}}} --port=${2:-${PSQL_PORT:-${default_port}}} --username=${3:-${PSQL_USER:-${default_user}}} --dbname=${5:-${PSQL_DB:-${default_database}}} --command='SELECT current_database(), current_user;' || echo -e "${colorRed}psql connection failed.${colorReset}"
}
export -f psql_test

functions | grep psql_

psql --version
