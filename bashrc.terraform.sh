script_echo Terraform setup...

alias tf=terraform
tfy() {
   ${ECHODO} terraform ${*} -auto-approve
}

# Enable Terraform cli tab autocomplete
(which terraform > /dev/null 2>&1) && complete -C /usr/bin/terraform terraform
