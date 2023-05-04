#! /bin/sh
echo Maven setup...

alias maven_list_plugins='mvn help:effective-pom | grep maven-plugin | grep artifactId | sed "s/[ \t]*//" | sed "s/<artifactId>//" | sed "s/-maven-plugin<\/artifactId>//" | sort --unique'
maven_list_goals() {
	plugin_search=${1:-.}
	for p in $(maven_list_plugins | grep ${plugin_search}); do
		mvn help:describe -Dplugin=${p} | grep -v INFO | grep -v WARNING;
	done
}
