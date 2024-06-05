script_echo Terraform setup...

alias tf=terraform
tfy() {
   ${ECHODO} terraform ${*} -auto-approve
}

