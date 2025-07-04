script_echo "Agora setup..."

##### DEV MODE #####

# Local PostgreSQL database; no Flyway migrations; schema from JPA entity defs; http://localhost:8080/h2-console admin/admin
function agora_dev_run() {
   if agora_dev_is_running; then
      "${BROWSER}" http://localhost:8080
      return 0
   fi
   ${ECHODO} sdk env install
   ${ECHODO} sdk env
   try docker-compose up -d postgres postgres-test
   try ./mvnw clean install spring-boot:run >agora.log 2>&1 &
   echo "fg, Ctrl-C to stop the madness"
   local while_tries=60
   local result=-1
   while [[ $result -ne 0 ]]; do
      if [[ ${while_tries} -lt 0 ]]; then
         echo "ERROR: Failed to start Agora."
         return 1
      else
         ((while_tries=while_tries-1))
         sleep 5
      fi
      echo -n "."
      $(curl --silent http://localhost:8080 >/dev/null 2>&1); result=$?
   done
   echo "Agora is running."
   "${BROWSER}" http://localhost:8080
}

# Local H2 database; no Flyway migrations; schema from JPA entity defs; http://localhost:8080/h2-console admin/admin
function agora_dev_run_h2() {
   if agora_dev_is_running; then
      return 0
   fi
   ${ECHODO} sdk env install
   ${ECHODO} sdk env
   try ./mvnw clean install
   try ./mvnw spring-boot:run -Dspring-boot.run.profiles=dev >agora.log 2>&1 &
   echo "fg, Ctrl-C to stop the madness"
   local while_tries=60
   local result=-1
   while [[ ${result} -ne 0 ]]; do
      if [[ ${while_tries} -lt 0 ]]; then
         echo "ERROR: Failed to start Agora."
         return 1
      else
         echo -n "."
         ((while_tries=while_tries-1))
         sleep 5
      fi
      $(curl --silent http://localhost:8080 >/dev/null 2>&1); result=$?
   done
   echo "Agora is running."
   "${BROWSER}" http://localhost:8080
}

function agora_dev_is_running() {
   if [[ $(curl --silent http://localhost:8080 | wc -l) -gt 0 ]]; then
      echo "Agora is running."
      return 0
   else
      echo "Agora is stopped."
      return 1
   fi
}

function agora_dev_kill() {
   ${ECHODO} kill $(ps aux | grep agora-backend | grep "spring-boot:" | awk '{print $2}')
   agora_dev_is_running
}

function agora_dev_restart() {
   agora_dev_kill 2>/dev/null
   agora_dev_run
}

#function agora_dev_start() {
#   ${ECHODO} mvn spring-boot:start -Dspring-boot.run.profiles=dev >agora.log 2>agora_dev.err &
#   echo "mvn spring-boot:stop to stop the madness"
#   local while_tries=30
#   local result=-1
#   while [ $result -ne 0 ]; do
#      if [[ ${while_tries} -lt 0 ]]; then
#         echo "ERROR: Failed to start Agora."
#         return 1
#      else
#         echo -n "."
#         ((while_tries=while_tries-1))
#         sleep 5
#      fi
#      $(curl --silent http://localhost:8080 >/dev/null 2>&1); result=$?
#   done
#   echo "Agora is running."
#   "${BROWSER}" http://localhost:8080
#}

# This only works with spring-boot:start; has no effect on spring-boot:run instances
#alias agora_dev_stop='${ECHODO} mvn spring-boot:stop'

# H2 database; no external dependencies; no Flyway migrations; JPA create-drop mode
alias agora_test_unit='mvn test' 

##### LOCAL MODE #####
# Postgres database local
function agora_test_integration() {
   try docker-compose up -d postgres test
   try ./mvnw test -Dspring.profiles.active=docker-test
}

alias | grep agora
functions | grep agora
