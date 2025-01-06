ARG PHP_VERSION=8.3
FROM dunglas/frankenphp:php${PHP_VERSION}-alpine

ARG ARG_TIMEZONE=Europe/Paris

RUN apk add --no-cache tzdata
ENV TZ=${ARG_TIMEZONE}
ENV CADDY_GLOBAL_OPTIONS="auto_https off"
ENV SERVER_NAME=:80

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