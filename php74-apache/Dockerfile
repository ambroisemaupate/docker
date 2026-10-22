# Rebuild EOL PHP 7.4.33 with the official php-src backport for
# CVE-2026-109618 and CVE-2026-109619 (branch PHP-7.4-CVE-2026-109618-109619)
FROM php:7.4-apache AS php-build

ARG PHP_FIX_COMMIT=712e60f9edfd03f0960fc4fc3c2c375f42b90aa2

RUN sed -i 's|deb.debian.org|archive.debian.org|g' /etc/apt/sources.list \
    && apt update \
    && apt install -y --no-install-recommends \
        $PHPIZE_DEPS \
        apache2-dev \
        git \
        libargon2-dev \
        libcurl4-openssl-dev \
        libonig-dev \
        libreadline-dev \
        libsodium-dev \
        libsqlite3-dev \
        libssl-dev \
        libxml2-dev \
        zlib1g-dev \
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
    && cd /usr/src \
    && tar -cJf php.tar.xz php \
    && rm -f php.tar.xz.asc

FROM php:7.4-apache
COPY --from=php-build /usr/local/ /usr/local/
COPY --from=php-build /usr/lib/apache2/modules/libphp7.so /usr/lib/apache2/modules/libphp7.so
# Patched sources, so docker-php-ext-install builds extensions against them
COPY --from=php-build /usr/src/php.tar.xz /usr/src/php.tar.xz
RUN rm -f /usr/src/php.tar.xz.asc
MAINTAINER Ambroise Maupate <ambroise@rezo-zero.com>
LABEL org.opencontainers.image.authors="Ambroise Maupate <ambroise@rezo-zero.com>"

ARG EXT_APCU_VERSION=v5.1.28

ENV APACHE_DOCUMENT_ROOT /var/www/html/web

# Debian bullseye is EOL, packages moved to archive.debian.org
RUN sed -i 's|deb.debian.org|archive.debian.org|g' /etc/apt/sources.list \
    && apt update \
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
#    APCu from GitHub (pecl.php.net is unreliable)
    && mkdir -p /usr/src/php/ext/apcu \
    && curl -fsSL https://codeload.github.com/krakjoe/apcu/tar.gz/refs/tags/${EXT_APCU_VERSION} | tar xz -C /usr/src/php/ext/apcu --strip 1 \
    && docker-php-ext-install -j${NPROC} $phpModules \
    && docker-php-ext-enable --ini-name 20-apcu.ini apcu \
    && apt autoremove \
    && apt clean

ADD etc/php/7.4/php.ini /usr/local/etc/php/php.ini
ADD etc/apache2/conf-available/cve-2026-109618.conf /etc/apache2/conf-available/cve-2026-109618.conf
RUN a2enconf cve-2026-109618

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
