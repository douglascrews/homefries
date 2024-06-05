script_echo Kubernetes setup...

# Install Minikube
#curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
#sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Install kubectl
#curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
#sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Docker/-compose/-machine
alias kc='kubectl'
alias k8s_cluster='k3d cluster list --no-headers | cut --delimiter=" " --only-delimited -f 1'
_k8s_use() {
	# Use the Nth cluster in the cluster list by default for kubectl operations.
	K8S_CLUSTER=$(kubectl cluster list --no-headers | head -${1:-1} | tail -1 | cut --delimiter=" " --only-delimited -f 1)
	echo Using ${K8S_CLUSTER}
	${ECHODO} k3d cluster get ${K8S_CLUSTER}
	${ECHODO} kubectl config use-context k3d-${K8S_CLUSTER}
}
alias k8s_use=_k8s_use
