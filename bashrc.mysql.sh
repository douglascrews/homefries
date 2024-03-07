echo "MySQL setup..."

# MySQL command line prompt (https://dev.mysql.com/doc/refman/8.0/en/mysql-commands.html)
export MYSQL_PS1="\u@\h (\v) [\d]> "

# Convenience/documentation function for MySQL connections
mysql_connect() {
	# default params
	local default_host=localhost
	local default_port=3306
	local default_user=root
	local default_password=
	local default_database=punchh_production
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
\t [database] Database to connect to (default \${MYSQL_DATABASE} or ${default_database})\n \
\t [protocol] Protocol to connect with (default \${MYSQL_PORT} or ${default_protocol})\n \
\t [comments?] Enable comments? (default \${MYSQL_COMMENTS} or ${default_comments})\n \
Parameters are numbered, so if you want to specify a database, you must also specify host, port, user, password. Sue me, I'm lazy.
"; \
		return 0; \
	}
	
	# If no first parameter passed, display default parameters used
	[[ -z "${1}" ]] && local use_echodo=echodo
	# If no password parameter passed, mangle the command line to request it entered manually
	[[ -n "${4:-${MYSQL_PW}}" ]] && local password_equal="="
	# Parameters are locational; order matters
	${use_echodo} mysql --host=${1:-${MYSQL_HOST:-localhost}} --port=${2:-${MYSQL_PORT:-3306}} --user=${3:-${MYSQL_USER:-root}} --password${password_equal}${4:-${MYSQL_PW}} --database=${5:-${MYSQL_DATABASE:-punchh_production}} --protocol=${6:-${MYSQL_PROTOCOL:-tcp}} --tee=mysql.log --comments=${7:-${MYSQL_COMMENTS:-true}}
}
