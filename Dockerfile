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
        && docker-php-ext-install imap opcache

#####################################
# OpCahce
#####################################
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=60'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

#####################################
# ZipArchive:
#####################################

RUN pecl install zip && \
    docker-php-ext-enable zip

#####################################
# Composer:
#####################################

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

#####################################
# Non-Root User:
#####################################

# Add a non-root user to prevent files being created with root permissions on host machine.
ARG PUID=1000
ARG PGID=1000
RUN groupadd -g $PGID laradock && \
    useradd -u $PUID -g laradock -m laradock

#####################################
# Set Timezone
#####################################

ARG TZ=UTC
ENV TZ ${TZ}
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

USER laradock
RUN composer global require "hirak/prestissimo:^0.3"
USER root