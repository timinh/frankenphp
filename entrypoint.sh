#!/usr/bin/env sh

# Récupération des variables d'env passées au container
printenv > /etc/environment

# Start supercronic using supervisord
supervisord -c /etc/supervisor/conf.d/supercronic.conf && supervisorctl start all

if [ -f /tmp/entrypoint.sh ]; then
    . /tmp/entrypoint.sh
fi

# Start FrankenPHP
frankenphp run caddy --config /etc/caddy/Caddyfile --adapter caddyfile