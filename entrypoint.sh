#!/usr/bin/env sh

# Récupération des variables d'env passées au container
printenv > /etc/environment

# Start supercronic using supervisord
supervisord -c /etc/supervisor/conf.d/supercronic.conf && sleep 2 && supervisorctl start supercronic

# Start FrankenPHP
frankenphp run caddy --config /etc/caddy/Caddyfile --adapter caddyfile