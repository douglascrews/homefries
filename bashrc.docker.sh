script_echo "Docker setup..."

# Docker/-compose/-machine
alias d='${ECHODO} docker'
alias dc='${ECHODO} docker-compose'
alias dce='${ECHODO} docker-compose exec'
alias dcu='${ECHODO} docker-compose up'
alias dps='${ECHODO} docker ps'
alias docker_clean_orphans='${ECHODO} docker rm $(docker ps -a -q -f status=exited)'
alias docker_clean_images='${ECHODO} docker rmi $(docker images --filter "dangling=true" -q --no-trunc)'
alias docker_purge='${ECHODO} docker system prune --force --volumes --all'
alias docker_required='(docker ps >/dev/null || ${ECHODO} "/mnt/c/Program Files/Docker/Docker/Docker Desktop.exe" &) && docker ps >/dev/null 2>&1'

function drun() {
   ${ECHODO} docker run -it --rm=true --name temp $2 $3 $4 $5 $6 $7 $8 $9 ${1:-busybox:latest}
}

function dbash() {
   ${ECHODO} docker exec -it ${1:-busybox:latest} bash $2 $3 $4 $5 $6 $7 $8 $9
}

function docker_ip() {
   ${ECHODO} docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${1:-"Container ID is needed"}
}

function d_mysql8() {
   ${ECHODO} docker_clean_orphans 2>/dev/null;
   ${ECHODO} docker run --detach --publish 127.0.0.1:3306:3306 --volume /var/log/docker/mysql8:/var/log/mysql --volume /var/lib/docker/mysql8:/var/lib/mysql --env MYSQL_ROOT_PASSWORD=password --env MYSQL_GENERAL_LOG=1 --name mysql8 cytopia/mysql-8.0 && dps --filter "name=mysql8"
}

function d_postgres {
   ${ECHODO} docker pull postgres
   ${ECHODO} docker run --detach --publish 127.0.0.1:5432:5432 --volume /var/log/docker/postgres:/var/log/postgres --volume /var/lib/docker/postgres:/var/lib/postgres --env POSTGRES_PASSWORD=password --name postgres postgres && dps --filter "name=postgres"
}

function d_build {
   ${ECHODO} docker buildx build --file=${1:-Dockerfile} .
}

function d_images {
   ${ECHODO} docker image list
}

function d_containers {
   docker container ls
}

#if [[ ! -x /usr/local/bin/docker-compose ]]; then
#  echo "Downloading Docker Compose latest..."
#  # Latest version: https://github.com/docker/compose/releases/latest
#  sudo curl -L https://github.com/docker/compose/releases/download/1.26.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose && sudo chmod +x /usr/local/bin/docker-compose
#fi

docker_required || echo "Starting Docker..."

docker --version
docker-compose --version
