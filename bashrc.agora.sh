script_echo "Agora setup..."

# H2 database; no external dependencies; no Flyway migrations; JPA create-drop mode
alias agora_test_unit='mvn test' 

# Postgres database local
function agora_test_integration() {
	docker-compose up -d postgres test
	mvn test -Dspring.profiles.active=docker-test
}

