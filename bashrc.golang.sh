script_echo "Golang setup..."

if [[ ! -x /usr/local/go/bin/go ]]; then
   echo "No GoLang executable found. Exiting ${0}..."
   return 1
fi

# Set PATH as needed
echo $PATH | grep /usr/local/go/bin >/dev/null 2>&1 || export PATH=${PATH}:/usr/local/go/bin

alias go_build='${ECHODO} go build -v -x .' # -v print packages as compiled; -x print commands
alias go_get='${ECHODO} go get -t -u -x all' # -t include tests; -u update minor/patch releases; -x print commands
alias go_run='${ECHODO} go run .'
alias go_tidy='${ECHODO} go mod tidy -v -x' # -v list removed modules to stderr; -x print commands

go version
