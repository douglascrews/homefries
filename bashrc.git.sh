script_echo "Git s[ucks]etup..."

# Install Git as needed
#git --version 2>/dev/null || sudo ${PACKAGE_MANAGER} -y install git

if [[ ! -a ~/.gitconfig ]]; then
   git config --global user.name "Douglas Crews"
   git config --global user.email "${git_email}"
   git config --global credential.helper store
   git config --global push.default simple
   git config --global core.autocrlf input
   git config --global core.excludesfile ~/.gitignore
   git config --global alias.hist 'log --pretty=format:\"%h %ad | %s%d [%an]\" --graph --date=short'
   git config --list
fi

eval $(ssh-agent -s) >/dev/null 2>&1

alias git_identities='ssh-add -l'
alias git_can_connect='ssh -T git@github.com'

if [[ $(ssh -T git@github.com >/dev/null 2>&1) -ne 1 ]]; then
   echo Adding default keys...
   ssh-add # ~/.ssh/id_rsa, ~/.ssh/id_dsa, ~/.ssh/id_ecdsa, ~/.ssh/id_ecdsa_sk, ~/.ssh/id_ed25519, and ~/.ssh/id_ed25519_sk
   ssh-add ~/.ssh/*.pem
   git_identities
   git_can_connect
fi

function git_branch_show
{
   git branch --show-current >/dev/null 2>&1 && echo "($(git branch --show-current))";
}
#export PS1="[\[${colorCyan}\]\u@\h\[${colorReset}\] \[${colorYellow}\]\W\[${colorReset}\]\$(git_branch_show)]\$ "

function git_revert() {
   ${ECHODO} git stash save
   git stash clear
   ${ECHODO} git submodule init
   ${ECHODO} git submodule update
   ${ECHODO} git clean -f -d -x
   ${ECHODO} git reset --hard
   git pull
   git status --show-stash
}
export -f git_revert

function git_pull() {
   #  --set-upstream docs say no param required/possible, but in practice it complains "you need to specify exactly one branch with the --set-upstream option"
   ${ECHODO} git pull --verbose --autostash --prune --progress # --recurse-submodules=yes --set-upstream
}
export -f git_pull

alias git_set_upstream='${ECHODO} git branch --set-upstream-to=origin/$(git symbolic-ref --short HEAD)'

function git_checkout() {
   ${ECHODO} git stash save
   ${ECHODO} git checkout -f -B ${1:-main} --track --recurse-submodules
   ${ECHODO} git branch --show-current
   ${ECHODO} git pull
   ${ECHODO} git status
}
export -f git_checkout

function git_branch_list() {
   ${ECHODO} git fetch --all --prune --refetch --recurse-submodules --set-upstream --progress
   ${ECHODO} git branch --all --list | grep ${1:-""}
}

alias git_status='${ECHODO} git status --show-stash --branch --verbose'

git config --global user.name >/dev/null || echo "Git username not set!"
git config --global user.email >/dev/null || echo "Git email not set!"

function git_generate_key() {
   echo "Generating GPG key..."
   gpg --full-generate-key

   echo "Listing GPG keys..."
   gpg --list-secret-keys --keyid-format LONG

   # Extract the GPG key ID
   KEY_ID=$(gpg --list-secret-keys --keyid-format LONG | grep -E 'sec.*rsa' | head -n 1 | awk '{print $2}' | cut -d'/' -f2)
   if [ -z "$KEY_ID" ]; then
       echo "Error: No GPG key found. Please ensure you generated a key."
       failed
   fi

   echo "Your GPG key ID is: $KEY_ID"

   echo "Configuring Git for GPG key..."
   git config --global user.signingkey "$KEY_ID"
   git config --global commit.gpgSign true
   git config --global gpg.program gpg

   echo "Exporting GPG public key..."
   gpg --armor --export "$KEY_ID" > ~/.ssh/gpgkey.asc
   echo "Your GPG public key has been saved to '~/.ssh/gpgkey.asc'."
   echo "Please copy the contents of this file to GitHub."

   # Open the GPG key file for easy copying
   if command -v xdg-open > /dev/null; then
       xdg-open ~/.ssh/gpgkey.asc
   elif command -v open > /dev/null; then
       open ~/.ssh/gpgkey.asc
   else
       echo "Unable to automatically open the file. Please open '~/.ssh/gpgkey.asc' manually."
   fi

   echo "Follow these steps to add the key to GitHub:"
   echo "1. Go to GitHub Settings -> SSH and GPG keys -> New GPG key"
   echo "2. Copy the contents of 'gpgkey.asc' and paste it into the key field."
   echo "3. Save the key."

   echo "Creating a test signed commit..."
   git commit -S -m "Test signed commit"

   echo "Pushing the signed commit..."
   git push

   echo "Check the commit on GitHub. You should see a 'Verified' badge next to the commit message."
}

#alias | grep git_
#functions | grep git_

git --version
