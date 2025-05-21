script_echo "PHP setup..."

php composer.phar --version 2>/dev/null && ${ECHODO} alias composer='php composer.phar'

alias | grep php

php -v

