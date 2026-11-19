# Rebuild EOL PHP 7.3.33 with Remi Collet's security backports, including
# CVE-2026-109618 and CVE-2026-109619 (branch PHP-7.3-security-backports)
FROM php:7.3-fpm-alpine AS php-build

ARG PHP_SRC_TAG=php-7.3.33
ARG PHP_FIX_REPO=https://github.com/remicollet/php-src-security.git
ARG PHP_FIX_COMMIT=15cf6860644ba512467468ffcf161baaeb431d2a

RUN apk add --no-cache \
        $PHPIZE_DEPS \
        argon2-dev \
        coreutils \
        curl-dev \
        git \
        gnu-libiconv-dev \
        libsodium-dev \
        libxml2-dev \
        linux-headers \
        openssl-dev \
        readline-dev \
        sqlite-dev \
        tar \
        xz \
    && git init -q /usr/src/php-fix \
    && git -C /usr/src/php-fix fetch -q --depth 1 https://github.com/php/php-src.git tag ${PHP_SRC_TAG} \
    && git -C /usr/src/php-fix fetch -q --depth 1 ${PHP_FIX_REPO} ${PHP_FIX_COMMIT} \
    && git -C /usr/src/php-fix diff --binary ${PHP_SRC_TAG} ${PHP_FIX_COMMIT} > /usr/src/php-fix.patch \
    && rm -rf /usr/src/php-fix \
    && rm -f /usr/include/iconv.h \
    && ln -sf /usr/include/gnu-libiconv/*.h /usr/include/ \
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

# nginx 1.30.7 from verified sources: the Alpine branch of this base image
# no longer ships security fixes (nginx2root CVEs). Paths are taken from the
# Alpine nginx package, whose binary is replaced in the final image.
FROM php:7.3-fpm-alpine AS nginx-build

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

FROM php:7.3-fpm-alpine
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
    && docker-php-ext-install -j${NPROC} exif json intl mbstring mysqli pdo pdo_mysql pdo_pgsql zip bz2 xml gmp \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/ --with-webp-dir=/usr/include/ \
    && docker-php-ext-install -j${NPROC} gd \
    && pecl install imagick apcu \
    && docker-php-ext-enable --ini-name 05-opcache.ini opcache \
    && docker-php-ext-enable --ini-name 20-imagick.ini imagick \
    && docker-php-ext-enable --ini-name 20-apcu.ini apcu \
    && apk del --no-cache gcc g++ freetype-dev libpng-dev libjpeg-turbo-dev .build-deps $PHPIZE_DEPS \
    # https://github.com/docker-library/php/issues/443
    && pecl update-channels \
    && rm -rf /tmp/pear ~/.pearrc

# PHP config
ADD etc/php/7.3/php.ini /usr/local/etc/php/php.ini
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
    && composer self-update --1

RUN chmod +x /before_launch.sh

# Add in your inheriting image to following lines
# to add your application code into server path.
#COPY . /var/www/html/
#VOLUME /var/www/html/files /var/www/html/web/files /var/www/html/app/logs /var/www/html/app/conf /var/www/html/app/gen-src

EXPOSE 80

ENTRYPOINT exec /usr/bin/supervisord -n -c /etc/supervisord.conf
