FROM php:7.1-fpm-alpine
MAINTAINER Ambroise Maupate <ambroise@rezo-zero.com>

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
    && apk --no-cache update \
    && apk --no-cache upgrade \
    && apk add --no-cache --virtual \
        .build-deps \
        $PHPIZE_DEPS \
        gcc g++ make \
        autoconf \
    && apk add --no-cache \
        libmcrypt-dev \
        curl \
        freetype-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        postgresql-dev \
        supervisor \
        bash \
        nginx \
        supervisor \
        pngquant jpegoptim \
        zip \
        icu-dev \
        dcron wget rsync ca-certificates \
    && NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) \
    && docker-php-ext-install -j${NPROC} exif json mcrypt intl mbstring mysqli pdo pdo_mysql pdo_pgsql zip  \
    && docker-php-ext-configure gd --with-gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/ \
    && docker-php-ext-install -j${NPROC} gd \
    && pecl install apcu \
    && docker-php-ext-enable --ini-name 05-opcache.ini opcache \
    && docker-php-ext-enable --ini-name 20-apcu.ini apcu \
    && docker-php-ext-enable --ini-name 20-mcrypt.ini mcrypt \
    && docker-php-ext-enable --ini-name 20-gd.ini gd \
    && apk del --no-cache gcc g++ make freetype-dev libpng-dev libjpeg-turbo-dev .build-deps \
    # https://github.com/docker-library/php/issues/443
    && pecl update-channels \
    && rm -rf /tmp/pear ~/.pearrc

# PHP config
ADD etc/php/7.1/php.ini /usr/local/etc/php/php.ini
ADD etc/php/zz-docker.conf /usr/local/etc/php-fpm.d/zz-docker.conf
ADD etc/nginx /etc/nginx
ADD etc/supervisord.ini /etc/supervisor.d/services.ini
#ADD etc/nginx/sites-available/000-default.conf /etc/nginx/sites-available/000-default.conf

# Add in your inheriting image to following lines
# to add your application code into server path.
#COPY . /var/www/html/
#VOLUME /var/www/html/files /var/www/html/web/files /var/www/html/app/logs /var/www/html/app/conf /var/www/html/app/gen-src

EXPOSE 80

ENTRYPOINT exec /usr/bin/supervisord -n -c /etc/supervisord.conf
#ENTRYPOINT ["/usr/bin/supervisord", "--nodaemon", "--configuration", "/etc/supervisord.conf"]
#CMD "/usr/bin/supervisord"
