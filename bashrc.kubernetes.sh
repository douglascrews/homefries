script_echo Kubernetes setup...

# Docker/-compose/-machine
alias kc='kubectl'
alias k=k3d
alias k8s_cluster='k cluster list --no-headers | cut --delimiter=" " --only-delimited -f 1'
_k8s_use() {
	# Use the Nth cluster in the cluster list by default for kubectl operations.
	K8S_CLUSTER=$(k cluster list --no-headers | head -${1:-1} | tail -1 | cut --delimiter=" " --only-delimited -f 1)
	echo Using ${K8S_CLUSTER}
	k cluster get ${K8S_CLUSTER}
	kubectl config use-context k3d-${K8S_CLUSTER}
}
alias k8s_use=_k8s_use
