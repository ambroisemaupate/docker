FROM php:7.4-fpm-alpine
MAINTAINER Ambroise Maupate <ambroise@rezo-zero.com>

RUN apk --no-cache update \
    && apk --no-cache upgrade \
    && apk add --no-cache --virtual \
        .build-deps \
        $PHPIZE_DEPS \
        gcc \
        g++ \
        autoconf \
        openssl \
        tar \
    && apk add --no-cache \
        make \
        shadow \
        libmcrypt-dev \
        mariadb-client \
        curl \
        freetype \
        libpng \
        libjpeg-turbo \
        freetype-dev \
        libpng-dev \
        libjpeg-turbo-dev \
        libwebp-dev \
        libzip-dev \
        bzip2-dev \
        postgresql-dev \
        supervisor \
        bash \
        nginx \
        pngquant \
        jpegoptim \
        zip \
        icu-dev \
        libxml2-dev \
        dcron \
        wget \
        rsync \
        ca-certificates \
        oniguruma-dev \
    && NPROC=$(getconf _NPROCESSORS_ONLN) \
    && docker-php-ext-install -j${NPROC} exif json intl mbstring mysqli pdo pdo_mysql pdo_pgsql zip bz2 xml \
    && docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j${NPROC} gd \
    && pecl install apcu \
    && docker-php-ext-enable --ini-name 05-opcache.ini opcache \
    && docker-php-ext-enable --ini-name 20-apcu.ini apcu \
    && apk del --no-cache gcc g++ freetype-dev libpng-dev libjpeg-turbo-dev .build-deps \
    # https://github.com/docker-library/php/issues/443
    && pecl update-channels \
    && rm -rf /tmp/pear ~/.pearrc

# Install composer and prestissimo plugin and put binary into $PATH
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/ \
    && ln -s /usr/local/bin/composer.phar /usr/local/bin/composer \
    && /usr/local/bin/composer global require hirak/prestissimo

# PHP config
ADD etc/php/7.4/php.ini /usr/local/etc/php/php.ini
ADD etc/php/zz-docker.conf /usr/local/etc/php-fpm.d/zz-docker.conf
ADD etc/nginx /etc/nginx
ADD etc/supervisord.ini /etc/supervisor.d/services.ini
# Add a chown script to clean UID on web root at
# each container restart
ADD etc/before_launch.ini /etc/supervisor.d/before_launch.ini
ADD etc/before_launch.sh /before_launch.sh

RUN chmod +x /before_launch.sh

# Add in your inheriting image to following lines
# to add your application code into server path.
#COPY . /var/www/html/
#VOLUME /var/www/html/files /var/www/html/web/files /var/www/html/app/logs /var/www/html/app/conf /var/www/html/app/gen-src

EXPOSE 80

ENTRYPOINT exec /usr/bin/supervisord -n -c /etc/supervisord.conf
