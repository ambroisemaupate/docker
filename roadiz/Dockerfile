FROM ambroisemaupate/nginx-php:latest
MAINTAINER Ambroise Maupate <ambroise@rezo-zero.com>

ENV ROADIZ_BRANCH master

RUN apt-get update -yqq && \
    apt-get install -y curl git cron pngquant jpegoptim && \
    sed -i'.original' 's/\;date.timezone \=/date.timezone = Europe\/Paris/' /etc/php/7.0/cli/php.ini && \
    sed -i'.original' 's/\;date.timezone \=/date.timezone = Europe\/Paris/' /etc/php/7.0/fpm/php.ini && \
    rm /etc/nginx/conf.d/02cache.conf

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && \
    mkdir -p /data/http

ADD config /config
ADD etc /etc
