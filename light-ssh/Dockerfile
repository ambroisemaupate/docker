FROM luzifer/sftp-share
MAINTAINER Ambroise Maupate <ambroise@rezo-zero.com>

## Use the same user name and UID as maxexcloo/data image
ENV USER core
ENV PASS changeme
ENV USER_UID 500

RUN apk --no-cache add perl openssl git zip curl nano mariadb-client php7 php7-mbstring \
                       php7-iconv php7-imap \
                       php7-curl php7-phar php7-pdo php7-pdo_mysql php7-pdo_sqlite \
                       php7-pdo_pgsql php7-xml php7-openssl php7-gd php7-mysqlnd php7-zip \
                       php7-pgsql php7-sqlite3 php7-json php7-intl php7-opcache && \
    curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && \
    composer self-update --1

ADD start.sh /usr/local/bin/start.sh
ADD etc /etc

ENTRYPOINT ["/bin/bash", "/usr/local/bin/start.sh"]
