# Rebuild EOL PHP 7.2.34 with Remi Collet's security backports, including
# CVE-2026-109618 and CVE-2026-109619 (branch PHP-7.2-Security-backports)
FROM php:7.2-fpm-alpine AS php-build

ARG PHP_SRC_TAG=php-7.2.34
ARG PHP_FIX_REPO=https://github.com/remicollet/php-src-security.git
ARG PHP_FIX_COMMIT=28cff42ed5a39f88ddf5db7285607d88df697844

RUN apk add --no-cache \
        $PHPIZE_DEPS \
        argon2-dev \
        coreutils \
        curl-dev \
        git \
        libedit-dev \
        libsodium-dev \
        libxml2-dev \
        linux-headers \
        openssl-dev \
        sqlite-dev \
        tar \
        xz \
    && git init -q /usr/src/php-fix \
    && git -C /usr/src/php-fix fetch -q --depth 1 https://github.com/php/php-src.git tag ${PHP_SRC_TAG} \
    && git -C /usr/src/php-fix fetch -q --depth 1 ${PHP_FIX_REPO} ${PHP_FIX_COMMIT} \
    && git -C /usr/src/php-fix diff --binary ${PHP_SRC_TAG} ${PHP_FIX_COMMIT} > /usr/src/php-fix.patch \
    && rm -rf /usr/src/php-fix \
    && docker-php-source extract \
    && cd /usr/src/php \
    && git apply /usr/src/php-fix.patch \
    && export CFLAGS="$PHP_CFLAGS" CPPFLAGS="$PHP_CPPFLAGS" LDFLAGS="$PHP_LDFLAGS" \
    && eval ./configure $(php-config --configure-options) \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && make install \
    && { find /usr/local -type f -perm /0111 -exec strip --strip-all {} + 2>/dev/null || true; } \
    && make clean \
    && cd /usr/src \
    && tar -cJf php.tar.xz php \
    && rm -f php.tar.xz.asc

FROM php:7.2-fpm-alpine
COPY --from=php-build /usr/local/ /usr/local/
# Patched sources, so docker-php-ext-install builds extensions against them
COPY --from=php-build /usr/src/php.tar.xz /usr/src/php.tar.xz
RUN rm -f /usr/src/php.tar.xz.asc
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
        bash \
        bzip2-dev \
        ca-certificates \
        curl \
        dcron \
        freetype \
        freetype-dev \
        gmp-dev \
        icu-dev \
        imagemagick \
        imagemagick-libs \
        jpegoptim \
        libjpeg-turbo \
        libjpeg-turbo-dev \
        libmcrypt-dev \
        libpng \
        libpng-dev \
        libwebp-dev \
        libxml2-dev \
        libzip-dev \
        make \
        mariadb-client \
        nginx \
        openssh-client \
        openssl \
        pngquant \
        postgresql-dev \
        rsync \
        shadow \
        sudo \
        supervisor \
        wget \
        zip \
    && docker-php-ext-install -j${NPROC} exif json intl mbstring mysqli pdo pdo_mysql pdo_pgsql zip xml \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/ --with-webp-dir=/usr/include/ \
    && docker-php-ext-install -j${NPROC} gd \
    && pecl install imagick apcu apcu_bc \
    && docker-php-ext-enable --ini-name 05-opcache.ini opcache \
    && docker-php-ext-enable --ini-name 20-apcu.ini apcu \
    && docker-php-ext-enable --ini-name 20-imagick.ini imagick \
    && docker-php-ext-enable --ini-name 30-apc.ini apc \
    && apk del --no-cache gcc g++ make freetype-dev libpng-dev libjpeg-turbo-dev .build-deps $PHPIZE_DEPS \
    # https://github.com/docker-library/php/issues/443
    && pecl update-channels \
    && rm -rf /tmp/pear ~/.pearrc

# PHP config
ADD etc/php/7.2/php.ini /usr/local/etc/php/php.ini
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
    && composer self-update --1

RUN chmod +x /before_launch.sh

# Add in your inheriting image to following lines
# to add your application code into server path.
#COPY . /var/www/html/
#VOLUME /var/www/html/files /var/www/html/web/files /var/www/html/app/logs /var/www/html/app/conf /var/www/html/app/gen-src

EXPOSE 80

ENTRYPOINT exec /usr/bin/supervisord -n -c /etc/supervisord.conf

