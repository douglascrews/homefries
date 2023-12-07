script_echo Docker setup...

# Docker/-compose/-machine
alias d='docker '
alias dc='docker-compose '
alias dce='docker-compose exec '
alias dcu='docker-compose up '
alias dps='docker ps'
alias docker_clean_orphans='docker rm $(docker ps -a -q -f status=exited)'
alias docker_clean_images='docker rmi $(docker images --filter "dangling=true" -q --no-trunc)'
alias docker_purge='docker system prune --force --volumes --all'
drun() {
	docker run -it --rm=true --name temp $2 $3 $4 $5 $6 $7 $8 $9 ${1:-busybox:latest}
}
dbash() {
	docker exec -it ${1:-busybox:latest} bash $2 $3 $4 $5 $6 $7 $8 $9
}
docker_ip() {
	docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${1:-"Container ID is needed"}
}
#if [[ ! -x /usr/local/bin/docker-compose ]]; then
#	echo "Downloading Docker Compose latest..."
#	# Latest version: https://github.com/docker/compose/releases/latest
#	sudo curl -L https://github.com/docker/compose/releases/download/1.26.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose && sudo chmod +x /usr/local/bin/docker-compose
#fi
