FROM ambroisemaupate/nginx-php:php7.0
MAINTAINER Ambroise Maupate <ambroise@rezo-zero.com>

ENV ROADIZ_BRANCH master

RUN apt-get update -yqq && \
    apt-get install -y curl git cron pngquant jpegoptim make && \
    sed -i'.original' 's/\;date.timezone \=/date.timezone = Europe\/Paris/' /etc/php/7.0/cli/php.ini && \
    sed -i'.original' 's/\;date.timezone \=/date.timezone = Europe\/Paris/' /etc/php/7.0/fpm/php.ini && \
    rm /etc/nginx/conf.d/02cache.conf

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && \
    mkdir -p /data/http

# Install Node JS and Yarn
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash - && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && \
    apt-get install -y nodejs yarn

ADD config /config
ADD etc /etc
