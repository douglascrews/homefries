script_echo "Docker setup..."

# Docker/-compose/-machine
alias d='${ECHODO} docker'
alias dc='${ECHODO} docker-compose'
alias dce='${ECHODO} docker-compose exec'
alias dcu='${ECHODO} docker-compose up -d'

function d_cleanup() {
   echo "Purging volumes..."
   ${ECHODO} docker volumes rm $(docker volume ls -q)
   ${ECHODO} docker system prune --volumes -f
   echo "Cleaning orphan containers..."
   ${ECHODO} docker rm $(docker ps -a -q -f status=exited)
   echo "Cleaning images..."
   ${ECHODO} docker rmi $(docker images --filter "dangling=true" -q --no-trunc)
   echo "Purging unused data..."
   ${ECHODO} docker system prune --force --volumes --all
}

function d_run() {
   [[ "${*}" =~ --help ]] || [[ "${#}" < 0 ]] && {
      help_note "Wrapper for " "*docker run"
      help_headline "${FUNCNAME}" "[image_name]" "[...]"
      help_param "[image_name]" "Docker image" "busybox:latest"
      help_param "[...]" "Additional parameters for 'docker run'"
      return 0;
   }
   local docker_image="busybox:latest"
   local docker_params=${@}
   if [[ "${#}" > 0 ]]; then
      docker_image=${1}
      docker_params=${docker_params[@]/${1}} # remove this param
   fi
   ${ECHODO} docker pull ${docker_image}
   ${ECHODO} docker run -it --rm=true --name temp ${docker_params} ${docker_image}
}

function d_bash() {
   [[ "${*}" =~ --help ]] || [[ "${#}" < 0 ]] && {
      help_note "Wrapper for " "*docker exec"
      help_headline "${FUNCNAME}" "[image_name]" "[...]"
      help_param "[image_name]" "Docker image" "busybox:latest"
      help_param "[...]" "Additional parameters for 'docker exec'"
      return 0;
   }
   local docker_image="busybox:latest"
   local docker_params=${@}
   if [[ "${#}" > 0 ]]; then
      docker_image=${1}
      docker_params=${docker_params[@]/${1}} # remove this param
   fi
   ${ECHODO} docker pull ${docker_image}
   ${ECHODO} docker exec -it ${docker_image} bash ${docker_params}
}

function d_ip() {
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
   [[ "${*}" =~ --help ]] || [[ "${#}" < 0 ]] && {
      help_note "Wrapper for " "*docker buildx build"
      help_headline "${FUNCNAME}" "[Dockerfile]" "[...]"
      help_param "[Dockerfile]" "Dockerfile filename" "Dockerfile"
      help_param "[...]" "Additional parameters for 'docker buildx build'"
      return 0;
   }
   local dockerfile=Dockerfile
   local docker_params=${@}
   if [[ "${#}" > 0 ]]; then
      dockerfile=${1}
      docker_params=${docker_params[@]/${1}} # remove this param
   fi
   ${ECHODO} docker buildx build --file=${dockerfile} . ${docker_params}
}

function d_ps {
   [[ "${*}" =~ --help ]] || [[ "${#}" < 0 ]] && {
      help_note "Wrapper for " "*docker ps"
      help_headline "${FUNCNAME}" "[--all]" "[--short|--long|--full] [...]"
      help_param "[--all]" "Show all containers" "only show running containers" # passed directly to docker as a param
      help_param "[--short]" "Use table format with useful fields"
      help_param "[--long]" "Use list format with newlines and all fields"
      help_param "[--full]" "Use table format with all fields"
      help_param "[...]" "\tAdditional parameters for 'docker ps'"
      return 0;
   }
   local docker_params=${@}
   local docker_format
   if [[ "${*}" =~ --short ]]; then
      docker_format="--format 'table {{.Names}}\t{{.ID}}\t{{.Image}}\t{{.Size}}\t{{.Command}}\t{{.State}}\t{{or .Ports \"(none)\"}}\t{{or .Networks \"(none)\"}}'"
      docker_params=${docker_params[@]/--short} # remove this param
   elif [[ "${*}" =~ --long ]]; then
      docker_format="--format 'Name: {{.Names}} ID: {{.ID}}\nImage: {{.Image}} Size: {{.Size}}\nCommand: {{.Command}}\nStatus: {{.State}} {{.RunningFor}} ({{.Status}})\tCreated: {{.CreatedAt}}\nPorts: {{or .Ports \"(none)\"}}\tNetworks: {{or .Networks \"(none)\"}}\nVolumes: {{.LocalVolumes}}\tMounts: {{.Mounts}}\nLabels: {{.Labels}}\n'"
      docker_params=${docker_params[@]/--long} # remove this param
   elif [[ "${*}" =~ --full ]]; then
      docker_format="--format 'table {{.Names}}\t{{.ID}}\t{{.Image}}\t{{.Size}}\t{{.Command}}\t{{.State}} {{.RunningFor}} ({{.Status}})\t{{.CreatedAt}}\t{{or .Ports \"(none)\"}}\t{{or .Networks \"(none)\"}}\t{{.LocalVolumes}}\t{{.Mounts}}\t{{.Labels}}'"
      docker_params=${docker_params[@]/--full} # remove this param
   fi
   ${ECHODO} docker ps ${docker_format} ${docker_params}
}

function d_images {
   [[ "${*}" =~ --help ]] || [[ "${#}" < 0 ]] && {
      help_note "Wrapper for " "*docker image list"
      help_headline "${FUNCNAME}" "[--short|--long|--full] [...]"
      help_param "[--short]" "Use table format with useful fields"
      help_param "[--long]" "Use list format with newlines and all fields"
      help_param "[--full]" "Use table format with all fields"
      help_param "[...]" "\tAdditional parameters passed to 'docker image list'"
      return 0;
   }
   local docker_params=${@}
   local docker_format
   if [[ "${*}" =~ --short ]]; then
      docker_format="--format 'table {{.ID}}\t{{.Repository}}\t{{.CreatedSince}}\t{{.Size}}\t{{.Containers}}\t{{.Tag}}'"
      docker_params=${docker_params[@]/--short} # remove this param
   elif [[ "${*}" =~ --long ]]; then
      docker_format="--format 'ID: {{.ID}} (in containers: {{.Containers}})\nRepo: {{.Repository}}\nCreated: {{.CreatedAt}} ({{.CreatedSince}})\nSize: {{.Size}} ({{.VirtualSize}} virtual, {{.SharedSize}} shared, {{.UniqueSize}} unique)\nTags: {{.Tag}}\n'"
      docker_params=${docker_params[@]/--long} # remove this param
   elif [[ "${*}" =~ --full ]]; then
      docker_format="--format 'table {{.ID}}\t{{.Digest}}\t{{.Repository}}\t{{.CreatedAt}}\t{{.CreatedSince}}\t{{.Containers}}\t{{.Tag}}\t{{.Size}}\t{{.SharedSize}}\t{{.UniqueSize}}\t{{.VirtualSize}}'"
      docker_params=${docker_params[@]/--full} # remove this param
   fi
   ${ECHODO} docker image list ${docker_format} ${docker_params}
}

function d_containers {
   ${ECHODO} docker container ls ${@}
}

function d_volumes {
   [[ "${*}" =~ --help ]] || [[ "${#}" < 0 ]] && {
      help_note "Wrapper for " "*docker volume list"
      help_headline "${FUNCNAME}" "[--short|--long|--full] [...]"
      help_param "[--short]" "Use table format with useful fields"
      help_param "[--long]" "Use list format with newlines and all fields"
      help_param "[--full]" "Use table format with all fields"
      help_param "[...]" "\tAdditional parameters passed to 'docker volume list'"
      return 0;
   }
   local docker_params=${@}
   local docker_format
   if [[ "${*}" =~ --short ]]; then
      docker_format="--format 'table {{.Name}}\t{{.Mountpoint}}'"
      docker_params=${docker_params[@]/--short} # remove this param
   elif [[ "${*}" =~ --long ]]; then
      docker_format="--format 'Name: {{.Name}}\nMountpoint: {{.Mountpoint}}\nDriver: {{.Driver}}\tScope: {{.Scope}}\tAvailability: {{.Availability}}\tGroup: {{.Group}}\tLinks: {{.Links}}\tSize: {{.Size}}\nStatus: {{.Status}}\nLabels: {{.Labels}}\n'"
      docker_params=${docker_params[@]/--long} # remove this param
   elif [[ "${*}" =~ --full ]]; then
      docker_format="--format 'table {{.Name}}\t{{.Mountpoint}}\n{{.Driver}}\t{{.Scope}}\t{{.Availability}}\t{{.Group}}\t{{.Links}}\t{{.Size}}\t{{.Status}}\t{{.Labels}}'"
      docker_params=${docker_params[@]/--full} # remove this param
   fi
   ${ECHODO} docker volume ls ${docker_format} ${docker_params}
}

#if [[ ! -x /usr/local/bin/docker-compose ]]; then
#  echo "Downloading Docker Compose latest..."
#  # Latest version: https://github.com/docker/compose/releases/latest
#  sudo curl -L https://github.com/docker/compose/releases/download/1.26.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose && sudo chmod +x /usr/local/bin/docker-compose
#fi

#docker_required || echo "Starting Docker..."

alias | grep docker
functions | grep docker
functions | grep " d_"

docker --version
docker-compose --version
