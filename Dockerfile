ARG PHP_VERSION=8.4
FROM dunglas/frankenphp:php${PHP_VERSION}-alpine

ARG ARG_TIMEZONE=Europe/Paris
ARG MERCURE_PUBLISHER_JWT_KEY=!ChangeThisMercureHubJWTSecretKey!
ARG MERCURE_SUBSCRIBER_JWT_KEY=!ChangeThisMercureHubJWTSecretKey!

RUN apk add --no-cache tzdata
ENV TZ=${ARG_TIMEZONE}
ENV CADDY_GLOBAL_OPTIONS="auto_https off"
ENV SERVER_NAME=:80
ENV MERCURE_PUBLISHER_JWT_KEY=${MERCURE_PUBLISHER_JWT_KEY}
ENV MERCURE_SUBSCRIBER_JWT_KEY=${MERCURE_SUBSCRIBER_JWT_KEY}

RUN apk add \
    bash \
    git \
    nano \
    vim \
    supervisor

RUN install-php-extensions \
    opcache \
    intl \
    mysqli \
    gd \
    ldap \
    gettext \
    calendar \
    ctype \
    session \
    dom \
    pdo \
    pdo_mysql \
    curl \
    exif \
    bcmath \
    amqp \
    redis \
    mongodb \
    soap \
    zip;

# Installation supercronic
# Latest releases available at https://github.com/aptible/supercronic/releases
ENV SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/v0.2.33/supercronic-linux-amd64 \
    SUPERCRONIC_SHA1SUM=71b0d58cc53f6bd72cf2f293e09e294b79c666d8 \
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