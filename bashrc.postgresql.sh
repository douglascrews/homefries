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
      help_headline ${FUNCNAME} [hostname] [port] [user] [password] [database] [additional psql params...]
      help_param '[host]' 'Hostname to connect to' "\${PGHOST} or ${default_host}"
      help_param '[port]' 'Port to connect to' "\${PGPORT} or ${default_port}"
      help_param '[user]' 'User to connect as' "\${PGUSER} or ${default_user}"
      help_param '[password]' 'Password to connect with' "\${PGPASSWORD}"
      help_param '[database]' 'Database to connect to' "\${PGDATABASE} or ${default_database}"
      help_param '[additional psql params...]' "See psql --help for additonal parameter options"
      help_note "Parameters are positional, so if you want to specify a database, you must also specify host, port, user, password. Sue me, I'm lazy."
      return 0
   }
   
   # Parameters are positional; order matters
   [[ -n "${1}" ]] && export PGHOST=${1:-${default_host}}
   [[ -n "${2}" ]] && export PGPORT=${2:-${default_port}}
   [[ -n "${3}" ]] && export PGUSER=${3:-${default_user}}
   [[ -n "${4}" ]] && export PGPASSWORD=${4:-${default_password}}
   [[ -n "${5}" ]] && export PGDATABASE=${5:-${default_database}}
   shift; shift; shift; shift; shift;
   
#   PGPASSWORD=${4:-${PGPASSWORD}} ${ECHODO} psql --host=${1:-${PGHOST:-${default_host}}} --port=${2:-${PGPORT:-${default_port}}} --username=${3:-${PGUSER:-${default_user}}} --dbname=${5:-${PGDATABASE:-${default_database}}}
   psql "${@}"
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
      help_param PGHOST "\${PGHOST} (${PGHOST})" ${default_host}
      help_param PGPORT "\${PGPORT} (${PGPORT})" ${default_port}
      help_param PGUSER "\${PGUSER} (${PGUSER})" ${default_user}
      help_param PSQL_PW "\t\${PSQL_PW} (\${PGPASSWORD})" $(([[ -n "${PGPASSWORD}" ]] && echo "(set)") || echo "(not set)")
      help_param PGDATABASE "\t\${PGDATABASE} (${PGDATABASE})" ${default_database}
      return 0;
   }
   
   set -o noglob # Do not expand the SQL command parameter into separate params, pass it as a string
   PGPASSWORD=${PGPASSWORD:=${default_password}} ${ECHODO} psql --host=${PGHOST:=${default_host}} --port=${PGPORT:=${default_port}} --username=${PGUSER:=${default_user}} --dbname=${PGDATABASE:=${default_database}} --dbname=${PGDATABASE:=${default_database}} --command="${*}"
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
      help_param "[host]" "Hostname to connect to" "\${PGHOST} or ${default_host}"
      help_param "[port]" "Port to connect to" "\${PGPORT} or ${default_port}"
      help_param "[user]" "User to connect as" "\${PGUSER} or ${default_user}"
      help_param "[password]" "Password to connect with" "\${PSQL_PW} or \${PGPASSWORD}"
      help_param "[database]" "Database to connect to" "\${PGDATABASE} or ${default_database}"
      help_param "[wait_seconds]" "Seconds to wait for connection" "\${PSQL_WAITSEC} or ${default_wait_seconds}"
      help_note "Parameters are positional, so if you want to specify a database, you must also specify host, port, user, password. Sue me, I'm lazy."
      return 0; \
   }

   # Parameters are positional; order matters
   PGHOST=${1:-${PGHOST:-${default_host}}}
   PGPORT=${2:-${PGPORT:-${default_port}}}
   PGUSER=${3:-${PGUSER:-${default_user}}}
   PSQL_PW=${4:-${PSQL_PW:-${default_password}}}
   PGDATABASE=${5:-${PGDATABASE:-${default_database}}}
   PSQL_WAITSEC=${6:-${PSQL_WAITSEC:-${default_wait_seconds}}}
   PGPASSWORD=${PSQL_PW} ${ECHODO} pg_isready --host=${PGHOST} --port=${PGPORT} --username=${PGUSER} --dbname=${PGDATABASE} --timeout=${PSQL_WAITSEC} || echo -e "${colorRed}psql connection failed.${colorReset}"
   # Fallback if pg_isready is not found
   #PGPASSWORD=${4:-${PSQL_PW}} ${ECHODO} psql --host=${1:-${PGHOST:-${default_host}}} --port=${2:-${PGPORT:-${default_port}}} --username=${3:-${PGUSER:-${default_user}}} --dbname=${5:-${PGDATABASE:-${default_database}}} --command='SELECT current_database(), current_user;' || echo -e "${colorRed}psql connection failed.${colorReset}"
}
export -f psql_test

functions | grep psql_

psql --version
