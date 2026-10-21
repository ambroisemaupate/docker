# 7.2 (Debian buster) or 7.4 (Debian bullseye)
ARG PHP_VERSION=7.2
FROM php:${PHP_VERSION}-fpm
MAINTAINER Ambroise Maupate <ambroise@rezo-zero.com>
LABEL org.opencontainers.image.authors="Ambroise Maupate <ambroise@rezo-zero.com>"

ARG EXT_APCU_VERSION=v5.1.28
ARG EXT_APCU_BC_VERSION=v1.0.5
ARG EXT_IMAGICK_VERSION=3.8.1
ARG NGINX_VERSION=1.30.5
ARG NGINX_SHA256=6c20565aa2325cb82216ae804f4a4ff1875179014759a381c42ddc8e11c4906d
ARG NODE_VERSION=8.17.0

ENV DEBIAN_FRONTEND noninteractive
ENV ROADIZ_BRANCH master

# Debian buster and bullseye are EOL, packages moved to archive.debian.org
RUN sed -i 's|deb.debian.org|archive.debian.org|g; s|security.debian.org|archive.debian.org|g; s|main$|main contrib non-free|' /etc/apt/sources.list \
    && apt-get -o Acquire::Check-Valid-Until=false update \
    && apt-get install -y -q --no-install-recommends \
        $PHPIZE_DEPS \
        ca-certificates \
        cron \
        curl \
        git \
        gnupg \
        inotify-tools \
        jpegoptim \
        locales \
        logrotate \
        make \
        mariadb-client \
        nano \
        openssh-client \
        pngquant \
        pwgen \
        supervisor \
        unrar \
        unzip \
        wget \
        xz-utils \
        libc-client-dev \
        libfreetype6-dev \
        libicu-dev \
        libjpeg-dev \
        libkrb5-dev \
        libmagickwand-dev \
        libpng-dev \
        libpcre3-dev \
        libpq-dev \
        libpspell-dev \
        librecode-dev \
        libssl-dev \
        libtidy-dev \
        libwebp-dev \
        libxml2-dev \
        libxslt-dev \
        libzip-dev \
        zlib1g-dev \
    && useradd -u 500 -d /data -s /bin/bash core \
    && mkdir -p /config /data/http
# Same extensions as former php7.2 Debian packages
RUN phpModules=" \
        apcu \
        calendar \
        exif \
        gd \
        gettext \
        imagick \
        imap \
        intl \
        mysqli \
        opcache \
        pcntl \
        pdo_mysql \
        pdo_pgsql \
        pgsql \
        pspell \
        shmop \
        sockets \
        sysvmsg \
        sysvsem \
        sysvshm \
        tidy \
        xmlrpc \
        xsl \
        zip \
    " \
    && NPROC=$(getconf _NPROCESSORS_ONLN) \
    && docker-php-source extract \
    # recode and wddx were removed in PHP 7.4
    && for ext in recode wddx; do [ -d /usr/src/php/ext/$ext ] && phpModules="$phpModules $ext"; done; \
    if dpkg --compare-versions "$PHP_VERSION" ge 7.4; then \
        docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp; \
    else \
        docker-php-ext-configure gd --with-freetype-dir=/usr --with-jpeg-dir=/usr --with-png-dir=/usr --with-webp-dir=/usr; \
    fi \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
#    APCu, APCu BC and Imagick from GitHub (pecl.php.net is unreliable)
    && mkdir -p /usr/src/php/ext/apcu /usr/src/php/ext/apc /usr/src/php/ext/imagick \
    && curl -fsSL https://codeload.github.com/krakjoe/apcu/tar.gz/refs/tags/${EXT_APCU_VERSION} | tar xz -C /usr/src/php/ext/apcu --strip 1 \
    && curl -fsSL https://codeload.github.com/krakjoe/apcu-bc/tar.gz/refs/tags/${EXT_APCU_BC_VERSION} | tar xz -C /usr/src/php/ext/apc --strip 1 \
    && curl -fsSL https://codeload.github.com/Imagick/imagick/tar.gz/refs/tags/${EXT_IMAGICK_VERSION} | tar xz -C /usr/src/php/ext/imagick --strip 1 \
    && docker-php-ext-install -j${NPROC} $phpModules \
    # apc.so must be loaded after apcu.so
    && docker-php-ext-install -j${NPROC} apc \
    && mv /usr/local/etc/php/conf.d/docker-php-ext-apc.ini /usr/local/etc/php/conf.d/zz-apc.ini \
    && docker-php-source delete \
    && cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini \
    && rm -f /usr/local/etc/php-fpm.d/*

# Nginx built from sources: nginx.org packages stop at 1.22 for buster
RUN curl -fsSL -o /tmp/nginx.tar.gz https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
    && echo "${NGINX_SHA256}  /tmp/nginx.tar.gz" | sha256sum -c - \
    && mkdir -p /usr/src/nginx /var/cache/nginx /var/log/nginx \
    && tar xzf /tmp/nginx.tar.gz -C /usr/src/nginx --strip 1 \
    && cd /usr/src/nginx \
    && ./configure \
        --prefix=/etc/nginx \
        --sbin-path=/usr/sbin/nginx \
        --conf-path=/etc/nginx/nginx.conf \
        --error-log-path=/var/log/nginx/error.log \
        --http-log-path=/var/log/nginx/access.log \
        --pid-path=/var/run/nginx.pid \
        --lock-path=/var/run/nginx.lock \
        --http-client-body-temp-path=/var/cache/nginx/client_temp \
        --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
        --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
        --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
        --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
        --with-file-aio \
        --with-threads \
        --with-pcre-jit \
        --with-http_ssl_module \
        --with-http_v2_module \
        --with-http_realip_module \
        --with-http_gzip_static_module \
        --with-http_stub_status_module \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && make install \
    && cd / \
    && rm -rf /usr/src/nginx /tmp/nginx.tar.gz /etc/nginx/html /etc/nginx/*.default \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Node JS and Yarn
RUN ARCH=$(dpkg --print-architecture | sed 's/amd64/x64/') \
    && curl -fsSL https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${ARCH}.tar.xz | tar xJ -C /usr/local --strip 1 --no-same-owner \
    && npm install -g yarn@1 \
    && npm cache clean --force

# Composer
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

ADD config /config
ADD etc /etc
ADD usr /usr
ADD supervisord.conf /etc/supervisor/conf.d/roadiz.conf
RUN chmod +x /config/loop

WORKDIR /
VOLUME /data
EXPOSE 80
STOPSIGNAL SIGTERM
CMD ["/config/loop"]
