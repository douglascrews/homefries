script_echo "Kubernetes setup..."

# Install Minikube
#curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
#sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Install kubectl
#curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
#sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install kubectx
# https://www.howtogeek.com/devops/how-to-quickly-switch-kubernetes-contexts-with-kubectx-and-kubens/
#(
#  set -x; cd "$(mktemp -d)" &&
#  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
#  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
#  KREW="krew-${OS}_${ARCH}" &&
#  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
#  tar zxvf "${KREW}.tar.gz" &&
#  ./"${KREW}" install krew
#)
#[[ -d "${KREW_ROOT:-$HOME/.krew}/bin" ]] && (echo ${PATH} | grep "${KREW_ROOT:-$HOME/.krew}/bin" >/dev/null || export PATH="${PATH}:${KREW_ROOT:-$HOME/.krew}/bin")
#kubectl krew
#kubectl krew install ctx
#kubectl krew install ns

# Docker/-compose/-machine
alias kc='kubectl'
alias k8s_cluster='k3d cluster list --no-headers | cut --delimiter=" " --only-delimited -f 1'
function k8s_use() {
   [[ "${*}" =~ --help ]] || [[ "${#}" < 1 ]] && {
      help_note 'Use the Nth cluster in the cluster list by default for kubectl operations.'
      help_headline ${FUNCNAME} 'cluster_ordinal'
      help_param 'cluster_ordinal' 'Which cluster in the list to use when not specified' '1'
      return 0;
   }
   K8S_CLUSTER=$(kubectl cluster list --no-headers | head -${1:-1} | tail -1 | cut --delimiter=" " --only-delimited -f 1)
   echo Using ${K8S_CLUSTER}
   ${ECHODO} k3d cluster get ${K8S_CLUSTER}
   ${ECHODO} kubectl config use-context k3d-${K8S_CLUSTER}
}
export -f k8s_use

kubectl version --short
