echo "Java setup..."

# Default some Spring Boot goals for Maven
alias sbrun="mvn spring-boot:run"
alias sbstop="mvn spring-boot:stop"
alias mvn_run=sbrun
alias mvn_stop=sbstop

# Pass environment variables to JVM system properties
JAVA_OPTS="${JAVA_TOOL_OPTIONS}"

# Add main class property
#JAVA_OPTS="${JAVA_OPTS} -Dloader.main=com.dougcrews.MyApp"

#echo "Database URL: ${SPRING_DATASOURCE_URL}"
#echo "Database Username: ${SPRING_DATASOURCE_USERNAME}"
echo "Spring profiles active: ${SPRING_PROFILES_ACTIVE}"

java --version
