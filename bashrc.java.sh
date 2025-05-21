echo "Java setup..."

# Default some Spring Boot goals for Maven
alias sbrun="mvn spring-boot:run"
alias sbstop="mvn spring-boot:stop"
alias mvn_run=sbrun
alias mvn_stop=sbstop

# SDKMAN https://sdkman.io/
if [[ -n "${SDKMAN_DIR}" ]]; then
   alias java_sdk_init='${ECHODO} sdk env init' # create .sdkmanrc in current directory
   alias java_sdk_install='${ECHODO} sdk env install' # install JDK version to disk
   alias java_sdk_use='${ECHODO} sdk env' # switch to .sdkmanrc JDK version
   alias | grep java_sdk
fi

# Pass environment variables to JVM system properties
JAVA_OPTS="${JAVA_TOOL_OPTIONS}"

# Add main class property
#JAVA_OPTS="${JAVA_OPTS} -Dloader.main=com.dougcrews.MyApp"

#echo "Database URL: ${SPRING_DATASOURCE_URL}"
#echo "Database Username: ${SPRING_DATASOURCE_USERNAME}"
echo "Spring profiles active: ${SPRING_PROFILES_ACTIVE}"

java --version
