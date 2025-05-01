script_echo "Dev Container setup..."

if [ -x ./.devcontainer/initializeCommand.sh ]; then
   . ./.devcontainer/initializeCommand.sh
fi

echo Executing /usr/local/share/docker-init.sh...
source /usr/local/share/docker-init.sh

echo Optional packages to install for local development environment
sudo apt-get update && export DEBIAN_FRONTEND=noninteractive \
     && sudo apt-get -y install --no-install-recommends \
     makeself \
     make \
     python3-venv \
     vim \
     xz-utils

echo Make a link to python3 for python
sudo ln -s /usr/bin/python3 /usr/bin/python 2>/dev/null

echo Persist bash history between runs
# https://code.visualstudio.com/docs/remote/containers-advanced#_persist-bash-history-between-runs
if [ ! -d /commandhistory ]; then
        SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.zsh_history" \
            && sudo mkdir /commandhistory 2>/dev/null \
            && sudo touch /commandhistory/.zsh_history \
            && sudo chown -R ${USER} /commandhistory \
            && echo $SNIPPET >> "/home/${USER}/.zshrc"
fi

# Script copies localhost's ~/.kube/config file into the container and swaps out
# localhost for host.docker.internal on bash/zsh start to keep them in sync.
if [ ! -f ./.devcontainer/copy-kube-config.sh ]; then
        echo Copying copy-kube-config.sh...
        sudo cp ./.devcontainer/copy-kube-config.sh /usr/local/share/
        sudo chown ${USER}:root /usr/local/share/copy-kube-config.sh && \
        echo "source /usr/local/share/copy-kube-config.sh" | \
        tee -a /root/.bashrc /root/.zshrc /home/${USER}/.bashrc >> /home/${USER}/.zshrc
fi

if [ -f ./.devcontainer/custom.zsh ]; then
        echo Copying custom.zsh...
        mkdir --parents /home/${USER}/.oh-my-zsh/custom 2>/dev/null
        sudo cp ./.devcontainer/custom.zsh /home/${USER}/.oh-my-zsh/custom/custom.zsh
fi

# [Optional] Uncomment this section to install additional OS packages.
sudo apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && sudo apt-get -y install --no-install-recommends vim uuid-runtime

export WORKSPACE=${PWD}
if [ -x ./.devcontainer/postCreateCommand.sh ]; then
   . ./.devcontainer/postCreateCommand.sh
fi

export git_home=github.com

ssh-add -l | grep ${git_home}.pem >/dev/null || ssh-add ~/.ssh/${git_home}.pem
ssh -T git@${git_home}
git submodule update --init --remote --recursive

if [ -x  ]; then
   source ./venv/bin/activate &>/dev/null
elif [ -x ./common-scripts/scripts/mkvenv.sh ]; then
   source ./common-scripts/scripts/mkvenv.sh
fi

echo Completed ~/.bashrc.devcontainer.
