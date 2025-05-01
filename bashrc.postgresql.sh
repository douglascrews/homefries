script_echo "PostgreSQL setup..."

# Convenience/documentation function for PostgreSQL connection
function psql_connect() {
   # default params
   local default_host=localhost
   local default_port=5432
   local default_user=postgres
   local default_password=postgres
   local default_database=information_schema

   # help
   [[ "${1}" == "--help" ]] || [[ "${1}" == "-h" ]] && { \
      echo -e "\
${FUNCNAME}() [hostname] [port] [user] [password] [database]\n \
\t [host] Hostname to connect to (default \${PSQL_HOST} or ${default_host})\n \
\t [port] Port to connect to (default \${PSQL_PORT} or ${default_port})\n \
\t [user] User to connect as (default \${PSQL_USER} or ${default_user})\n \
\t [password] Password to connect with (default \${PSQL_PW} or \${PGPASSWORD})\n \
\t [database] Database to connect to (default \${PSQL_DB} or ${default_database})\n \
Parameters are numbered, so if you want to specify a database, you must also specify host, port, user, password. Sue me, I'm lazy. \
"; \
      return 0; \
   }
   
   # Parameters are locational; order matters
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
   [[ "${1}" == "--help" ]] || [[ "${1}" == "-h" ]] && { \
      echo -e " \
${FUNCNAME}() \"[SQL command]\"\n \
\t You may need to define the following environment variables:\n \
\t PSQL_HOST (default ${PSQL_HOST:-${default_host}})\n \
\t PSQL_PORT (default ${PSQL_PORT:-${default_port}})\n \
\t PSQL_USER (default ${PSQL_USER:-${default_user}})\n \
\t PSQL_PW (DEFAULT \${PGPASSWORD})\n \
\t PSQL_DB (default ${PSQL_DB:-${default_database}})\n \
"; \
      return 0; \
   }
   
   set -o noglob
   PGPASSWORD=${4:-${PSQL_PW}} psql --host=${PSQL_HOST:-${default_host}} --port=${PSQL_PORT:-${default_port}} --username=${PSQL_USER:-${default_user}} --dbname=${PSQL_DB:-${default_database}} --dbname=${PSQL_DB:-${default_database}} --command="${*}"
}
export -f psql_run

psql --version
