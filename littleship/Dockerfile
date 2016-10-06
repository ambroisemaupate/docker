FROM ambroisemaupate/nginx-php:latest
MAINTAINER Ambroise Maupate <ambroise@rezo-zero.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -yqq && \
    apt-get install -y curl git && \
    curl -sL https://deb.nodesource.com/setup_4.x | bash - && \
    apt-get update -yqq && \
    apt-get install -y nodejs && \
    npm install -g grunt-cli && \
    npm install -g bower && \
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer && \
    addgroup --gid 999 docker && \
    usermod -aG docker core  && \
    mkdir -p /data/http

ADD config /config

# override default vhost to use symfony root folder (/web)
ADD etc/nginx/host.d/default.conf /etc/nginx/host.d/default.conf

