FROM php:5.6-fpm

MAINTAINER AttractGroup

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        libmemcached-dev \
        libz-dev \
        libjpeg-dev \
        libpng12-dev \
        libfreetype6-dev \
        libssl-dev \
        libmcrypt-dev \
        git

# Install the PHP mcrypt extention
RUN docker-php-ext-install mcrypt

# Install the PHP pdo_mysql extention
RUN docker-php-ext-install pdo_mysql

RUN apt-get purge --auto-remove -y zlib1g-dev \
        && apt-get -y install libssl-dev libc-client2007e-dev libkrb5-dev \
        && docker-php-ext-configure imap --with-imap-ssl --with-kerberos \
        && docker-php-ext-install imap

#####################################
# ZipArchive:
#####################################

RUN pecl install zip && \
    docker-php-ext-enable zip

#####################################
# Composer:
#####################################

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

COPY ./composer.json /var/www/project/composer.json

ENV COMPOSER_ALLOW_SUPERUSER 1
RUN /var/www/composer install