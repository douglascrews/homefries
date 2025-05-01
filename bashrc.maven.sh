script_echo "Maven setup..."

export M2_HOME=$(ls --directory /usr/local/apache-maven/apache-maven* --reverse | head -n 1)
if [[ -z "${M2_HOME}" ]]; then
   echo "ERROR: Maven not found in /usr/local/apache-maven/"
   return 1
fi
#echo "M2_HOME=${M2_HOME}"
export M2=${M2_HOME}/bin
export MAVEN_OPTS="-Xms256m -Xmx512m"
#echo "MAVEN_OPTS=${MAVEN_OPTS}"
export PATH=${PATH}:${M2}/bin

alias maven_list_plugins='mvn help:effective-pom | grep maven-plugin | grep artifactId | sed "s/[ \t]*//" | sed "s/<artifactId>//" | sed "s/-maven-plugin<\/artifactId>//" | sort --unique'
maven_list_goals() {
   plugin_search=${1:-.}
   for p in $(maven_list_plugins | grep ${plugin_search}); do
      mvn help:describe -Dplugin=${p} | grep -v INFO | grep -v WARNING;
   done
}

#which mvn
mvn --version
