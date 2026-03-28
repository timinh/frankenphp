ARG VERSION=8.4-alpine

FROM dunglas/frankenphp:builder-php${VERSION} AS builder

# Copier xcaddy dans l'image du constructeur
COPY --from=caddy:builder /usr/bin/xcaddy /usr/bin/xcaddy

# CGO doit être activé pour construire FrankenPHP
RUN CGO_ENABLED=1 \
    XCADDY_SETCAP=1 \
    XCADDY_GO_BUILD_FLAGS="-ldflags='-w -s' -tags=nobadger,nomysql,nopgx" \
    CGO_CFLAGS=$(php-config --includes) \
    CGO_LDFLAGS="$(php-config --ldflags) $(php-config --libs)" \
    xcaddy build \
        --output /usr/local/bin/frankenphp \
        --with github.com/dunglas/frankenphp=./ \
        --with github.com/dunglas/frankenphp/caddy=./caddy/ \
        --with github.com/dunglas/caddy-cbrotli \
        --with github.com/dunglas/mercure/caddy \
        --with github.com/dunglas/vulcain/caddy \
        # module pour les logs apache
        --with github.com/caddyserver/transform-encoder

# Image finale
FROM dunglas/frankenphp:php${VERSION}

# Copier le binaire FrankenPHP compilé avec l'extension
COPY --from=builder /usr/local/bin/frankenphp /usr/local/bin/frankenphp

ARG ARG_TIMEZONE=Europe/Paris
ARG MERCURE_PUBLISHER_JWT_KEY=!ChangeThisMercureHubJWTSecretKey!
ARG MERCURE_SUBSCRIBER_JWT_KEY=!ChangeThisMercureHubJWTSecretKey!

RUN apk update && apk add --no-cache tzdata bash git nano vim supervisor procps curl libzip-dev libxml2-dev
ENV TZ=${ARG_TIMEZONE}
ENV CADDY_GLOBAL_OPTIONS="auto_https off"
ENV SERVER_NAME=:80
ENV MERCURE_PUBLISHER_JWT_KEY=${MERCURE_PUBLISHER_JWT_KEY}
ENV MERCURE_SUBSCRIBER_JWT_KEY=${MERCURE_SUBSCRIBER_JWT_KEY}

RUN install-php-extensions \
    opcache \
    intl \
    mysqli \
    gd \
    ldap \
    gettext \
    bcmath \
    pdo_mysql \
    pdo_pgsql \
    pgsql \
    apcu \
    soap \
    xsl \
    zip

# Install PECL extensions separately as they may not be stable for PHP 8.5 yet
RUN install-php-extensions amqp || true
RUN install-php-extensions mongodb || true
RUN install-php-extensions redis || true
RUN install-php-extensions xdebug || true
RUN install-php-extensions oci8 || true

# Installation supercronic
ENV SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/v0.2.41/supercronic-linux-amd64 \
    SUPERCRONIC_SHA1SUM=f70ad28d0d739a96dc9e2087ae370c257e79b8d7 \
    SUPERCRONIC=supercronic-linux-amd64

RUN curl -fsSLO "$SUPERCRONIC_URL" \
 && echo "${SUPERCRONIC_SHA1SUM}  ${SUPERCRONIC}" | sha1sum -c - \
 && chmod +x "$SUPERCRONIC" \
 && mv "$SUPERCRONIC" "/usr/local/bin/${SUPERCRONIC}" \
 && ln -s "/usr/local/bin/${SUPERCRONIC}" /usr/local/bin/supercronic

COPY ./supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY ./crontab /etc/crontabs/crontab

COPY --from=composer/composer:2-bin /composer /usr/local/bin/composer
COPY ./php.ini /usr/local/etc/php/php.ini
COPY ./Caddyfile /etc/caddy/Caddyfile
ENV COMPOSER_ALLOW_SUPERUSER=1

COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
