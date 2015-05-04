FROM maxexcloo/nginx-php:latest
MAINTAINER Ambroise Maupate <ambroise@rezo-zero.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -yqq && \
    apt-get install -y \
    curl \
    git \
    php5-curl \
    php5-intl \
    php5-cli && \
    curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && \
    addgroup --gid 999 docker && \
    usermod -aG docker core  && \
    mkdir -p /data/http

ADD config /config

