FROM luzifer/sftp-share
MAINTAINER Ambroise Maupate <ambroise@rezo-zero.com>

## Use the same user name and UID as maxexcloo/data image
ENV USER core
ENV PASS changeme
ENV USER_UID 500

RUN apk --no-cache add git zip curl nano mariadb-client php7-cli \
                       php7-curl php7-openssl php7-gd php7-mysql php7-zip \
                       php7-pgsql php7-sqlite php7-json && \
    curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer

ADD start.sh /usr/local/bin/start.sh
ADD etc /etc

ENTRYPOINT ["/bin/bash", "/usr/local/bin/start.sh"]