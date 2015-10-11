FROM luzifer/sftp-share
MAINTAINER Ambroise Maupate <ambroise@rezo-zero.com>

## Use the same user name and UID as maxexcloo/data image
ENV USER core
ENV PASS changeme
ENV USER_UID 500

RUN apt-get update && \
    apt-get install -y git zip curl nano mariadb-client php5-fpm php5-cli php5-curl php5-gd php5-mcrypt php5-mysqlnd php5-pgsql php5-sqlite && \
    apt-get clean && \
    curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer

ADD etc /etc