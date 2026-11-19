# PHP 7.4.33 sources, as verified by the official image build
FROM php:7.4-fpm-alpine AS php-src

# Upgrade EOL PHP 7.4.6 to 7.4.33 with the official php-src backport for
# CVE-2026-109618 and CVE-2026-109619 (branch PHP-7.4-CVE-2026-109618-109619),
# keeping Alpine 3.10 system libraries (curl 7.66)
FROM php:7.4-fpm-alpine3.10 AS php-build

ARG PHP_FIX_COMMIT=712e60f9edfd03f0960fc4fc3c2c375f42b90aa2

COPY --from=php-src /usr/src/php.tar.xz /usr/src/php.tar.xz

RUN rm -f /usr/src/php.tar.xz.asc \
    && apk add --no-cache \
        $PHPIZE_DEPS \
        argon2-dev \
        coreutils \
        curl-dev \
        git \
        libedit-dev \
        libsodium-dev \
        libxml2-dev \
        linux-headers \
        oniguruma-dev \
        openssl-dev \
        patch \
        sqlite-dev \
        tar \
        xz \
    && git init -q /usr/src/php-fix \
    && git -C /usr/src/php-fix fetch -q --depth 2 https://github.com/php/php-src.git ${PHP_FIX_COMMIT} \
    && git -C /usr/src/php-fix diff FETCH_HEAD^ FETCH_HEAD > /usr/src/php-fix.patch \
    && docker-php-source extract \
    && cd /usr/src/php \
    && patch -p1 --forward < /usr/src/php-fix.patch \
    && export CFLAGS="$PHP_CFLAGS" CPPFLAGS="$PHP_CPPFLAGS" LDFLAGS="$PHP_LDFLAGS" \
    && eval ./configure $(php-config --configure-options) \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && make install \
    && { find /usr/local -type f -perm /0111 -exec strip --strip-all {} + 2>/dev/null || true; } \
    && make clean \
    && cp php.ini-* "$PHP_INI_DIR/" \
    && cd /usr/src \
    && tar -cJf php.tar.xz php

# nginx 1.30.7 from verified sources: the Alpine branch of this base image
# no longer ships security fixes (nginx2root CVEs). Paths are taken from the
# Alpine nginx package, whose binary is replaced in the final image.
FROM php:7.4-fpm-alpine3.10 AS nginx-build

ARG NGINX_VERSION=1.30.7
ARG NGINX_SHA256=2565b5c837050e958f70fb0f73c48e2bca4542ad349fd356f46fb0c72610bc6e

RUN apk add --no-cache nginx curl gcc make libc-dev linux-headers openssl-dev pcre-dev zlib-dev \
    && curl -fsSL -o /tmp/nginx.tar.gz https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
    && echo "${NGINX_SHA256}  /tmp/nginx.tar.gz" | sha256sum -c - \
    && mkdir -p /usr/src/nginx \
    && tar xzf /tmp/nginx.tar.gz -C /usr/src/nginx --strip 1 \
    && cd /usr/src/nginx \
    && ./configure \
        $(nginx -V 2>&1 | sed -n 's/^configure arguments: //p' | tr ' ' '\n' | grep -E '^--(prefix|user|group|[a-z-]+-path)=') \
        --with-threads \
        --with-file-aio \
        --with-pcre-jit \
        --with-http_ssl_module \
        --with-http_v2_module \
        --with-http_realip_module \
        --with-http_addition_module \
        --with-http_sub_module \
        --with-http_dav_module \
        --with-http_flv_module \
        --with-http_mp4_module \
        --with-http_gunzip_module \
        --with-http_gzip_static_module \
        --with-http_auth_request_module \
        --with-http_random_index_module \
        --with-http_secure_link_module \
        --with-http_slice_module \
        --with-http_stub_status_module \
    && make -j$(getconf _NPROCESSORS_ONLN)

FROM php:7.4-fpm-alpine3.10
ENV PHP_VERSION=7.4.33
COPY --from=php-build /usr/local/ /usr/local/
# Patched sources, so docker-php-ext-install builds extensions against them
COPY --from=php-build /usr/src/php.tar.xz /usr/src/php.tar.xz
RUN rm -f /usr/src/php.tar.xz.asc
MAINTAINER Ambroise Maupate <ambroise@rezo-zero.com>
LABEL org.opencontainers.image.authors="Ambroise Maupate <ambroise@rezo-zero.com>"

ARG EXT_APCU_VERSION=v5.1.28
ARG EXT_IMAGICK_VERSION=3.8.1

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
        libxml2-dev \
        libxslt-dev \
        libzip-dev \
        make \
        mysql-client \
        # alpine 3.10 only
        musl-dev libc-dev libgcrypt-dev \
        net-snmp-dev \
        nginx \
        oniguruma-dev \
        openldap-dev \
        openssh-client \
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
        sockets \
        sysvmsg \
        sysvsem \
        sysvshm \
        tidy \
        xsl \
        zip \
    " \
    && docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp \
#    PECL extensions from GitHub (pecl.php.net is unreliable)
#    @see https://github.com/docker-library/php/issues/1029
    && mkdir -p /usr/src/php/ext/apcu \
    && curl -fsSL https://codeload.github.com/krakjoe/apcu/tar.gz/refs/tags/${EXT_APCU_VERSION} | tar xz -C /usr/src/php/ext/apcu --strip 1 \
    && mkdir -p /usr/src/php/ext/imagick \
    && curl -fsSL https://codeload.github.com/Imagick/imagick/tar.gz/refs/tags/${EXT_IMAGICK_VERSION} | tar xz -C /usr/src/php/ext/imagick --strip 1 \
    && docker-php-ext-install -j${NPROC} $phpModules imagick \
    && docker-php-ext-enable --ini-name 20-apcu.ini apcu \
    && apk del --no-cache gcc g++ freetype-dev libpng-dev libjpeg-turbo-dev .build-deps $PHPIZE_DEPS

ADD etc/php/7.4/php.ini /usr/local/etc/php/php.ini
ADD etc/php/zz-docker.conf /usr/local/etc/php-fpm.d/zz-docker.conf
COPY --from=nginx-build /usr/src/nginx/objs/nginx /usr/sbin/nginx
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
