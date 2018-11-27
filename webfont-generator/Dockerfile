FROM php:7.2-fpm-stretch
MAINTAINER Ambroise Maupate <ambroise@rezo-zero.com>

ENV DEBIAN_FRONTEND=noninteractive
ENV WWW_DATA_UID=1000
ENV WWW_DATA_GID=1000
ENV BUILD_DEPS="build-essential autoconf libtool automake git cmake zlib1g-dev libmcrypt-dev libssl-dev libbz2-dev libicu-dev python3-pip"
ENV RUN_DEPS="brotli fontforge woff-tools nginx zip unzip supervisor bash python3"
ENV PHP_EXTS="zip intl opcache pcntl"

# Install fontforge and woof-tools
RUN apt-get update \
    && apt-get install --no-install-recommends -y ${BUILD_DEPS} ${RUN_DEPS} \
    && echo_supervisord_conf > /etc/supervisord.conf \
    && docker-php-ext-install $PHP_EXTS \
    && docker-php-ext-enable $PHP_EXTS \
    && which fontforge \
    && which sfnt2woff

# Install https://github.com/wget/ttf2eot
RUN git clone https://github.com/wget/ttf2eot.git \
    && cd ttf2eot \
    && make \
    && chmod a+x ttf2eot \
    && mv ttf2eot /bin/ttf2eot \
    && cd ../

# Install libbrotli
RUN git clone https://github.com/bagder/libbrotli \
    && cd libbrotli \
    && ./autogen.sh \
    && ./configure \
    && make \
    && make install \
    && cd ../

# Google Woff2
RUN git clone https://github.com/google/woff2.git \
    && cd woff2 \
    && mkdir out \
    && cd out \
    && cmake .. \
    && make \
    && make install \
    && mv woff2_compress /usr/bin/woff2_compress \
    && cd ../../

# Python3 font tools for subsetting
RUN pip3 install fonttools \
    && which pyftsubset

# Install composer and put binary into $PATH
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/ \
    && ln -s /usr/local/bin/composer.phar /usr/local/bin/composer

RUN rm -rf /var/www/html && mkdir -p /var/www/html \
    && cd /var/www/html \
    && git clone https://github.com/ambroisemaupate/webfont-generator.git . \
    && composer install --no-plugins --no-scripts -o -n

RUN apt-get purge -y --auto-remove ${BUILD_DEPS} \
    && rm -rf ttf2eot libbrotli woff2 \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && usermod -u ${WWW_DATA_UID} www-data \
    && groupmod -g ${WWW_DATA_GID} www-data \
    && chown -R www-data:www-data /var/www/html

ADD etc/php/7.2/php.ini /usr/local/etc/php/php.ini
ADD etc/php/zz-docker.conf /usr/local/etc/php-fpm.d/zz-docker.conf
ADD etc/nginx /etc/nginx
ADD etc/supervisord.conf /etc/supervisord.conf
ADD etc/before_launch.ini /etc/supervisor/conf.d/00_before_launch.conf
ADD etc/services.ini /etc/supervisor/conf.d/01_services.conf
ADD etc/before_launch.sh /before_launch.sh
ADD config.docker.yml /var/www/html/config.yml

EXPOSE 80

ENTRYPOINT exec /usr/bin/supervisord -n -c /etc/supervisord.conf
