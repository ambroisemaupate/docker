FROM ambroisemaupate/nginx:latest
MAINTAINER Ambroise Maupate <ambroise@rezo-zero.com>

RUN apt-get install -y -qq apt-transport-https lsb-release ca-certificates && \
    wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
    echo "deb https://packages.sury.org/php/ buster main" > /etc/apt/sources.list.d/php.list && \
    apt-get update && \
    apt-get install -y -q --no-install-recommends mariadb-client php5-cli php5-curl php5-fpm php5-gd php5-json \
                       php5-intl php5-imap php5-pspell \
                       php5-tidy php5-xmlrpc php5-xsl php5-apcu \
                       php5-mysqlnd php5-pgsql php5-mcrypt php5-imagick && \
    apt-get clean && \
    echo -n > /var/lib/apt/extended_states && \
    rm -rf /etc/nginx/addon.d /etc/php5/fpm/pool.d && \
    mkdir -p /etc/nginx/addon.d /etc/php5/fpm/pool.d && \
    rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && \
    mkdir -p /data/http
    
ADD etc /etc
RUN php5enmod tuning
ADD supervisord.conf /etc/supervisor/conf.d/php-fpm.conf
