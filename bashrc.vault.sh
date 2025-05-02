script_echo "Vault setup..."

# Local setup
export VAULT_ADDR=https://localhost:8200
export VAULT_STRIPE=dev
export VAULT_BRANCH=secret/blah/yecch/${VAULT_STRIPE}
export VAULT_CACERT="This value needs to be set locally"
export VAULT_USER=${USER}

vaultlogin_curl() {
   VAULTPW=${VAULT_PW}
   [[ -n "${VAULTPW}" ]] || (read -p "Password: " -s VAULTPW && echo "(got it)")
   PAYLOAD="{\"password\":\"${VAULTPW:-${VAULT_PW}}\"}"
#  echo payload = ${PAYLOAD}
   STRIPE=${1:-${VAULT_STRIPE}}
   CACERT=${2}
   if [[ -z ${CACERT} ]]; then
      echo CACERT is required!
   fi
   echo curl --cacert ${CACERT} -H "Content-Type:application/json" -L -X POST -d "'${PAYLOAD}'" ${VAULT_ADDR}/v1/auth/${STRIPE}/login/${VAULT_USER:-${USER}}
   (    curl --cacert ${CACERT} -H "Content-Type:application/json" -L -X POST -d "'${PAYLOAD}'" ${VAULT_ADDR}/v1/auth/${STRIPE}/login/${VAULT_USER:-${USER}} | jq --join-output '.auth.client_token // empty' | tee ~/.vault-token)
   [[ -s ~/.vault-token ]] && echo Success
   unset VAULTPW
   unset STRIPE
   unset CACERT
   unset PAYLOAD

#   curl --cacert ${VAULT_CACERT} -H '"Content-Type: application/json"' -L -X POST -d "'{"'"password"':'"'${VAULT_PW}'"'"}'" ${VAULT_ADDR}/v1/auth/${VAULT_STRIPE}/login/${VAULT_USER:-${USER}} | jq '.auth.client_token' | tee ~/.vault-token 2>&1 && echo "Success"
}

vaultlist_curl() {
   curl --cacert ${VAULT_CACERT} -H "X-Vault-Token:`cat ~/.vault-token`" --request LIST ${VAULT_ADDR}/v1/blah/yecch/metadata/${VAULT_STRIPE}
}

alias vaultlogin_native="vault auth -method=ldap -path=${VAULT_STRIPE} username=${VAULT_USER}"

alias vaultlogin=vaultlogin_curl

vm() {
   vaultmanager --configfile=.vaultmanager --token=`cat ~/.vault-token` $*
}

_vault_write() {
   vault_leaf=${1};
   shift;
   secret=`vault read ${VAULT_BRANCH}/${vault_leaf}`
   [ -n "${secret}" ] && read -p "*** VALUE EXISTS ***. Ctrl-C to abort. " -n 1
   [ -z "${secret}" ] && read -p "Creating new secret. Ctrl-C to abort. " -n 1
   unset secret
   vault write ${VAULT_BRANCH}/${vault_leaf} ${*}
}
alias vault_write=_vault_write

_vault_read() {
   ${ECHODO} vault read ${2} ${3} ${4} ${5} ${6} ${7} ${8} ${9} ${VAULT_BRANCH}/${1}
}
alias vault_read=_vault_read

_vault_get() {
       ${ECHODO}   curl --insecure --cacert ${VAULT_CACERT} -H "X-Vault-Token:`cat ~/.vault-token`" -L -X GET ${VAULT_ADDR}/v1/${VAULT_BRANCH}/${1}
}
alias vault_get=_vault_get

_vault_list() {
   ${ECHODO} vault list ${2} ${3} ${4} ${5} ${6} ${7} ${8} ${9} ${VAULT_BRANCH}/${1}
}
alias vault_list=_vault_list

_vault_del() {
   vault_leaf=${1};
   shift;
   secret=`vault read ${VAULT_BRANCH}/${vault_leaf}`
   [ -n "${secret}" ] && read -p "Value exists. Ctrl-C to abort. " -n 1
   [ -z "${secret}" ] && read -p "***Nothing there to delete***. Ctrl-C to abort. " -n 1
   unset secret
   vault delete ${VAULT_BRANCH}/${vault_leaf}
}
alias vault_del=_vault_del

#declare -F | grep vault
#declare -F | grep vm
alias | grep vault
vault --version
