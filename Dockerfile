ARG PHP_VERSION=8.3
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
    redis \
    git \
    nano \
    vim

RUN install-php-extensions \
    opcache \
    pdo \
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
    zip \
    redis\
    mongodb;

COPY --from=composer/composer:2-bin /composer /usr/local/bin/composer
COPY ./php.ini /usr/local/etc/php/php.ini
ENV COMPOSER_ALLOW_SUPERUSER=1