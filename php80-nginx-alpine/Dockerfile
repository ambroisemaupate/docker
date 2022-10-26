ARG PHP_VERSION=8.0
FROM php:${PHP_VERSION}-fpm-alpine
MAINTAINER Ambroise Maupate <ambroise@rezo-zero.com>

RUN apk --no-cache update \
    && apk --no-cache upgrade \
    && apk add --no-cache --virtual \
        .build-deps \
        $PHPIZE_DEPS \
        gcc \
        g++ \
        autoconf \
        tar \
        imagemagick-dev \
        libtool \
    && export CFLAGS="$PHP_CFLAGS" CPPFLAGS="$PHP_CPPFLAGS" LDFLAGS="$PHP_LDFLAGS" NPROC=$(getconf _NPROCESSORS_ONLN) \
    && apk add --no-cache \
        aspell-dev \
        bash \
        bzip2-dev \
        ca-certificates \
        curl \
        dcron \
        freetds-dev \
        freetype \
        freetype-dev \
        gettext-dev \
        gmp-dev \
        icu-dev \
        icu-data-full \
        imagemagick \
        imagemagick-libs \
        imap-dev \
        jpegoptim \
        libintl \
        libjpeg-turbo \
        libjpeg-turbo-dev \
        libmcrypt-dev \
        libpng \
        libpng-dev \
        libwebp-dev \
#       No AVIF support until php8.1
#       libavif-dev \
        libxml2-dev \
        libxslt-dev \
        libzip-dev \
        make \
        mysql-client \
        net-snmp-dev \
        nginx \
        nginx-mod-http-brotli \
        oniguruma-dev \
        openldap-dev \
        openssh \
        openssl \
        pngquant \
        postgresql-dev \
        rsync \
        shadow \
        sudo \
        supervisor \
        tidyhtml-dev \
        wget \
        zip \
    && phpModules=" \
        apcu \
        bcmath \
        bz2 \
        calendar \
        exif \
        gd \
        imagick \
        gettext \
        gmp \
        imap \
        intl \
        opcache \
        pcntl \
        pdo \
        pdo_mysql \
        pdo_pgsql \
        pgsql \
        pspell \
        shmop \
        snmp \
        soap \
        tidy \
        xsl \
        zip \
    " \
    # No AVIF support until php8.1
    # && docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp --with-avif \
    && docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp \
#    Install APCU
#    @see https://github.com/docker-library/php/issues/1029
    && mkdir -p /usr/src/php/ext/apcu  \
    && curl -fsSL https://pecl.php.net/get/apcu | tar xvz -C "/usr/src/php/ext/apcu" --strip 1 \
#    && curl -fsSL https://pecl.php.net/get/apcu-5.1.20.tgz | tar xvz -C "/usr/src/php/ext/apcu" --strip 1 \
    # install imagick
    # use github version for now until release from https://pecl.php.net/get/imagick is ready for PHP 8
    && mkdir -p /usr/src/php/ext/imagick \
    && curl -fsSL https://pecl.php.net/get/imagick | tar xvz -C "/usr/src/php/ext/imagick" --strip 1 \
    && docker-php-ext-install -j${NPROC} $phpModules \
    && docker-php-ext-enable --ini-name 20-apcu.ini apcu \
    && docker-php-ext-enable --ini-name 20-imagick.ini imagick \
    && apk del --no-cache gcc g++ freetype-dev libpng-dev libjpeg-turbo-dev .build-deps $PHPIZE_DEPS

ADD etc/php/8.0/php.ini /usr/local/etc/php/php.ini
ADD etc/php/zz-docker.conf /usr/local/etc/php-fpm.d/zz-docker.conf
ADD etc/nginx /etc/nginx
ADD etc/supervisord.ini /etc/supervisor.d/services.ini
# Add a chown script to clean UID on web root at
# each container restart
ADD etc/before_launch.ini /etc/supervisor.d/before_launch.ini
ADD etc/before_launch.sh /before_launch.sh

# Install composer and put binary into $PATH
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/ \
    && ln -s /usr/local/bin/composer.phar /usr/local/bin/composer \
    && chmod +x /before_launch.sh

# Add in your inheriting image to following lines
# to add your application code into server path.
#COPY . /var/www/html/
#VOLUME /var/www/html/files /var/www/html/web/files /var/www/html/app/logs /var/www/html/app/conf /var/www/html/app/gen-src

EXPOSE 80

ENTRYPOINT exec /usr/bin/supervisord -n -c /etc/supervisord.conf
