FROM ambroisemaupate/nginx:latest
MAINTAINER Ambroise Maupate <ambroise@rezo-zero.com>

RUN apt-get install -y -qq apt-transport-https lsb-release ca-certificates && \
    wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
    echo "deb https://packages.sury.org/php/ buster main" > /etc/apt/sources.list.d/php.list && \
    apt-get update && \
    apt-get install -y -q --no-install-recommends mariadb-client php7.2-cli php7.2-curl php7.2-fpm php7.2-gd php7.2-zip php7.2-json \
                       php7.2-opcache php7.2-intl php7.2-imap php7.2-pspell php7.2-recode \
                       php7.2-tidy php7.2-xmlrpc php7.2-xsl php7.2-apcu php7.2-apcu-bc \
                       php7.2-mysql php7.2-pgsql php7.2-sqlite3 php7.2-mbstring php-mbstring php7.2-imagick && \
    apt-get clean && \
    echo -n > /var/lib/apt/extended_states && \
    rm -rf /etc/nginx/addon.d /etc/php/7.2/fpm/pool.d && \
    mkdir -p /etc/nginx/addon.d /etc/php/7.2/fpm/pool.d && \
    rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && \
    mkdir -p /data/http
    
ADD etc /etc
RUN phpenmod tuning
ADD supervisord.conf /etc/supervisor/conf.d/php-fpm.conf
