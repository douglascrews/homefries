if [[ ! -x /usr/local/go/bin/go ]]; then
   echo "No GoLang executable found. Exiting ${0}..."
   return 1
fi

# Set PATH as needed
echo $PATH | grep /usr/local/go/bin >/dev/null 2>&1 || export PATH=${PATH}:/usr/local/go/bin

go version