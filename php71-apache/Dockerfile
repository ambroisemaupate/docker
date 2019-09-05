FROM php:7.1-apache
MAINTAINER Ambroise Maupate <ambroise@rezo-zero.com>

# PHP extensions
ENV APCU_VERSION 5.1.7
# Reflect a Roadiz / Symfony public path
ENV APACHE_DOCUMENT_ROOT /var/www/html/web

RUN buildDeps=" \
        libicu-dev \
        libcurl4-gnutls-dev \
        zlib1g-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
    " \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        $buildDeps \
        libicu63 \
        zlib1g \
        curl \
        pngquant \
        jpegoptim \
        libmcrypt-dev \
        libfreetype6-dev \
    && docker-php-ext-install -j$(nproc) iconv mcrypt intl mbstring pdo_mysql zip curl  \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && pecl install apcu-$APCU_VERSION \
    && docker-php-ext-enable --ini-name 05-opcache.ini opcache \
    && docker-php-ext-enable --ini-name 20-apcu.ini apcu \
    && docker-php-ext-enable --ini-name 20-mcrypt.ini mcrypt \
    && docker-php-ext-enable --ini-name 20-gd.ini gd \
    && apt-get purge -y --auto-remove $buildDeps \
    && apt-get clean \
    && a2enmod rewrite headers expires

# PHP config
ADD etc/php/7.1/php.ini /usr/local/etc/php/php.ini
ADD etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/000-default.conf

# Add in your inheriting image to following lines
# to add your application code into server path.
#COPY . /var/www/html/
#VOLUME /var/www/html/files /var/www/html/web/files /var/www/html/app/logs /var/www/html/app/conf /var/www/html/app/gen-src
