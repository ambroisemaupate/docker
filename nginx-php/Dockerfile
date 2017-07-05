FROM ambroisemaupate/nginx:latest
MAINTAINER Ambroise Maupate <ambroise@rezo-zero.com>
RUN apt-get install -y -qq apt-transport-https lsb-release ca-certificates && \
    wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
    echo "deb https://packages.sury.org/php/ jessie main" > /etc/apt/sources.list.d/php.list && \
    apt-get update && \
    apt-get install -y mysql-client php7.1-cli php7.1-curl php7.1-fpm php7.1-gd php7.1-mcrypt php7.1-zip php7.1-json \
                       php7.1-opcache php7.1-intl php7.1-imap php7.1-pspell php7.1-recode \
                       php7.1-tidy php7.1-xmlrpc php7.1-xsl php7.1-apcu php7.1-apcu-bc \
                       php7.1-mysql php7.1-pgsql php7.1-sqlite3 php7.1-mbstring php7.1-imagick && \
    apt-get clean && \
    echo -n > /var/lib/apt/extended_states
RUN rm -rf /etc/nginx/addon.d /etc/php/7.1/fpm/pool.d && \
    mkdir -p /etc/nginx/addon.d /etc/php/7.1/fpm/pool.d
ADD etc /etc
RUN phpenmod tuning
ADD supervisord.conf /etc/supervisor/conf.d/php-fpm.conf
