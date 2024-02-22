script_echo Terraform setup...

alias tf=terraform
tfy() {
   terraform ${*} -auto-approve
}

