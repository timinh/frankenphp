ARG VERSION=8.3
FROM dunglas/frankenphp:php${VERSION}-alpine

ARG ARG_TIMEZONE=Europe/Paris

RUN apk add --no-cache tzdata
ENV TZ=${ARG_TIMEZONE}

ENV SERVER_NAME=:80

RUN apk add \
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
ENV COMPOSER_ALLOW_SUPERUSER=1