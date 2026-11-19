# Rebuild EOL PHP 8.1.34 with the official php-src backport for
# CVE-2026-109618 and CVE-2026-109619 (branch PHP-8.1-CVE-2026-109618-109619)
FROM php:8.1-fpm-alpine AS php-build

ARG PHP_FIX_COMMIT=1d7dec178a094e6e75b229ce22754045f8c6070a

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
        oniguruma-dev \
        openssl-dev \
        patch \
        patchutils \
        readline-dev \
        sqlite-dev \
        tar \
        xz \
    && git init -q /usr/src/php-fix \
    && git -C /usr/src/php-fix fetch -q --depth 2 https://github.com/php/php-src.git ${PHP_FIX_COMMIT} \
    && git -C /usr/src/php-fix diff FETCH_HEAD^ FETCH_HEAD > /usr/src/php-fix.patch \
    && rm -f /usr/include/iconv.h \
    && ln -sf /usr/include/gnu-libiconv/*.h /usr/include/ \
    && docker-php-source extract \
    && cd /usr/src/php \
    # Same upstream patches as the official image build
    && curl -fL 'https://github.com/php/php-src/commit/577b8ae4226368e66fee7a9b5c58f9e2428372fc.patch?full_index=1' -o 11678.patch \
    && echo '6edc20c3bb3e7cc13515abce7f2fffa8ebea6cf7469abfbc78fcdc120350b239 *11678.patch' | sha256sum -c - \
    && patch -p1 < 11678.patch \
    && curl -fL 'https://github.com/php/php-src/commit/a5df26691d1b1f71b964b869510473a5d5413999.patch?full_index=1' -o 19131.patch \
    && echo 'c98c01c74d3a6da197116f8511b16fed361ca6bbb6a8af8df629a933f541c213 *19131.patch' | sha256sum -c - \
    && patch --reverse -p1 < 19131.patch \
    && curl -fL 'https://github.com/php/php-src/commit/67259e451d5d58b4842776c5696a66d74e157609.patch?full_index=1' -o 14834.patch \
    && echo 'ed10a1b254091ad676ed204e55628ecbd6c8962004d6185a1821cedecd526c0f *14834.patch' | sha256sum -c - \
    && filterdiff -x '*/NEWS' 14834.patch | patch -p1 \
    && rm *.patch \
    && patch -p1 --forward < /usr/src/php-fix.patch \
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
FROM php:8.1-fpm-alpine AS nginx-build

ARG NGINX_VERSION=1.30.7
ARG NGINX_SHA256=2565b5c837050e958f70fb0f73c48e2bca4542ad349fd356f46fb0c72610bc6e
ARG NGX_BROTLI_VERSION=1.0.0rc
ARG NGX_BROTLI_SHA256=c85cdcfd76703c95aa4204ee4c2e619aa5b075cac18f428202f65552104add3b

RUN apk add --no-cache nginx curl gcc make libc-dev linux-headers openssl-dev pcre-dev zlib-dev brotli-dev \
    && curl -fsSL -o /tmp/nginx.tar.gz https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
    && echo "${NGINX_SHA256}  /tmp/nginx.tar.gz" | sha256sum -c - \
    && mkdir -p /usr/src/nginx \
    && tar xzf /tmp/nginx.tar.gz -C /usr/src/nginx --strip 1 \
    && curl -fsSL -o /tmp/ngx_brotli.tar.gz https://codeload.github.com/google/ngx_brotli/tar.gz/refs/tags/v${NGX_BROTLI_VERSION} \
    && echo "${NGX_BROTLI_SHA256}  /tmp/ngx_brotli.tar.gz" | sha256sum -c - \
    && mkdir -p /usr/src/ngx_brotli \
    && tar xzf /tmp/ngx_brotli.tar.gz -C /usr/src/ngx_brotli --strip 1 \
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
        --add-dynamic-module=/usr/src/ngx_brotli \
    && make -j$(getconf _NPROCESSORS_ONLN)

FROM php:8.1-fpm-alpine
COPY --from=php-build /usr/local/ /usr/local/
# Patched sources, so docker-php-ext-install builds extensions against them
COPY --from=php-build /usr/src/php.tar.xz /usr/src/php.tar.xz
RUN rm -f /usr/src/php.tar.xz.asc
MAINTAINER Ambroise Maupate <ambroise@rezo-zero.com>
LABEL org.opencontainers.image.authors="Ambroise Maupate <ambroise@rezo-zero.com>"

RUN apk --no-cache update \
    && apk --no-cache upgrade \
    && apk add --no-cache --virtual \
        .build-deps \
        $PHPIZE_DEPS \
        gcc \
        g++ \
        autoconf \
        pcre-dev \
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
        libavif \
        libavif-dev \
        libwebp-dev \
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
        tidy \
        xsl \
        zip \
    " \
    && docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp --with-avif \
#    Install APCU
#    @see https://github.com/docker-library/php/issues/1029
    && mkdir -p /usr/src/php/ext/apcu  \
    && curl -fsSL https://pecl.php.net/get/apcu/stable | tar xvz -C "/usr/src/php/ext/apcu" --strip 1 \
    # install imagick
    && pecl install imagick \
    && docker-php-ext-install -j${NPROC} $phpModules \
    && docker-php-ext-enable --ini-name 20-apcu.ini apcu \
    && docker-php-ext-enable --ini-name 20-imagick.ini imagick \
    # install redis
    && pecl install redis \
    && docker-php-ext-enable redis.so \
    && apk del --no-cache gcc g++ freetype-dev libpng-dev libjpeg-turbo-dev .build-deps $PHPIZE_DEPS

ADD etc/php/8.1/php.ini /usr/local/etc/php/php.ini
ADD etc/php/zz-docker.conf /usr/local/etc/php-fpm.d/zz-docker.conf
COPY --from=nginx-build /usr/src/nginx/objs/nginx /usr/sbin/nginx
COPY --from=nginx-build /usr/src/nginx/objs/ngx_http_brotli_filter_module.so /usr/src/nginx/objs/ngx_http_brotli_static_module.so /usr/lib/nginx/modules/
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
