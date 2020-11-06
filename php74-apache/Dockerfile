FROM php:7.4-apache
MAINTAINER Ambroise Maupate <ambroise@rezo-zero.com>

ENV APACHE_DOCUMENT_ROOT /var/www/html/web

RUN apt update \
    && apt install -y \
        $PHPIZE_DEPS \
        ${PHP_EXTRA_BUILD_DEPS:-} \
        bash \
        ca-certificates \
        cron \
        curl \
        jpegoptim \
        make \
        mariadb-client \
        openssl \
        pngquant \
        rsync \
        sudo \
        supervisor \
        wget \
        zip \
        zlib1g-dev \
        libzip-dev \
        libpng-dev \
        libwebp-dev \
        libjpeg-dev \
        libfreetype6-dev \
        libbz2-dev \
        libgmp-dev \
        re2c \
        libmhash-dev \
        libmcrypt-dev \
        file \
        libicu-dev \
        libpspell-dev \
        libxml2-dev \
        libxslt-dev \
    && phpModules=" \
        apcu \
        bcmath \
        bz2 \
        calendar \
        exif \
        gd \
        gettext \
        gmp \
        intl \
        opcache \
        pcntl \
        pdo \
        pdo_mysql \
        pspell \
        shmop \
        soap \
        sockets \
        sysvmsg \
        sysvsem \
        sysvshm \
        xsl \
        zip \
    " \
    && NPROC=$(getconf _NPROCESSORS_ONLN) \
    && docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp \
    && mkdir -p /usr/src/php/ext/apcu  \
    && curl -fsSL https://pecl.php.net/get/apcu | tar xvz -C "/usr/src/php/ext/apcu" --strip 1 \
    && docker-php-ext-install -j${NPROC} $phpModules \
    && docker-php-ext-enable --ini-name 20-apcu.ini apcu \
    && apt autoremove \
    && apt clean

ADD etc/php/7.4/php.ini /usr/local/etc/php/php.ini
ADD etc/php/zz-docker.conf /usr/local/etc/php-fpm.d/zz-docker.conf

# Install composer and put binary into $PATH
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/ \
    && ln -s /usr/local/bin/composer.phar /usr/local/bin/composer \
    && sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf \
    && sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Add in your inheriting image to following lines
# to add your application code into server path.
#COPY . /var/www/html/
#VOLUME /var/www/html/files /var/www/html/web/files /var/www/html/app/logs /var/www/html/app/conf /var/www/html/app/gen-src
