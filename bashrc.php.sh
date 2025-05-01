script_echo "PHP setup..."

php -v
php composer.phar --version 2>/dev/null && ${ECHODO} alias composer='php composer.phar'

