FROM php:8.2-bullseye

ARG NODE_VERSION=18

RUN additionalPackages=" \
        apt-transport-https \
        git \
        msmtp-mta \
        openssh-client \
        rsync \
    " \
    buildDeps=" \
        freetds-dev \
        libbz2-dev \
        libc-client-dev \
        libfreetype6-dev \
        libgmp3-dev \
        libicu-dev \
        libjpeg62-turbo-dev \
        libkrb5-dev \
        libldap2-dev \
        libmcrypt-dev \
        libonig-dev \
        libpq-dev \
        libpspell-dev \
        librabbitmq-dev \
        libsasl2-dev \
        libsnmp-dev \
        libssl-dev \
        libtidy-dev \
        libwebp-dev \
        libxml2-dev \
        libxslt1-dev \
        zlib1g-dev \
    " \
    && runDeps=" \
        gnupg \
        libc-client2007e \
        libfreetype6 \
        libicu67 \
        libjpeg62-turbo \
        libmcrypt4 \
        libpng-dev \
        libpng16-16 \
        libpq5 \
        libsybdb5 \
        libtidy5deb1 \
        libx11-6 \
        libxslt1.1 \
        libzip-dev \
        snmp \
    " \
    && phpModules=" \
        amqp \
        apcu \
        bcmath \
        bz2 \
        calendar \
        dba \
        exif \
        gd \
        gettext \
        gmp \
        imap \
        intl \
        ldap \
        mysqli \
        opcache \
        pcntl \
        pdo \
        pdo_dblib \
        pdo_mysql \
        pdo_pgsql \
        pgsql \
        pspell \
        redis \
        shmop \
        snmp \
        soap \
        tidy \
        xsl \
        zip \
    " \
    && NPROC=$(getconf _NPROCESSORS_ONLN) \
    && echo "deb http://security.debian.org/debian-security bullseye-security main contrib non-free" > /etc/apt/sources.list.d/additional.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends $additionalPackages $buildDeps $runDeps \
    && docker-php-source extract \
    && cd /usr/src/php/ext/ \
    && ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h \
    && ln -s /usr/lib/x86_64-linux-gnu/libldap_r.so /usr/lib/libldap.so \
    && ln -s /usr/lib/x86_64-linux-gnu/libldap_r.a /usr/lib/libldap_r.a \
    && ln -s /usr/lib/x86_64-linux-gnu/libsybdb.a /usr/lib/libsybdb.a \
    && ln -s /usr/lib/x86_64-linux-gnu/libsybdb.so /usr/lib/libsybdb.so \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && PHP_OPENSSL=yes docker-php-ext-configure imap --with-imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-configure ldap --with-ldap-sasl \
#    Install APCU
#    @see https://github.com/docker-library/php/issues/1029
    && mkdir -p /usr/src/php/ext/apcu  \
    && mkdir -p /usr/src/php/ext/amqp  \
    && mkdir -p /usr/src/php/ext/igbinary  \
    && mkdir -p /usr/src/php/ext/mongodb  \
    && mkdir -p /usr/src/php/ext/redis  \
    && curl -fsSL https://pecl.php.net/get/apcu | tar xvz -C "/usr/src/php/ext/apcu" --strip 1 \
#    AMQP ext fails at compilation
    && curl -fsSL https://pecl.php.net/get/amqp | tar xvz -C "/usr/src/php/ext/amqp" --strip 1 \
    && curl -fsSL https://pecl.php.net/get/igbinary | tar xvz -C "/usr/src/php/ext/igbinary" --strip 1 \
    && curl -fsSL https://pecl.php.net/get/mongodb | tar xvz -C "/usr/src/php/ext/mongodb" --strip 1 \
    && curl -fsSL https://pecl.php.net/get/redis | tar xvz -C "/usr/src/php/ext/redis" --strip 1 \
#    Install xdebug manually
    && pecl install xdebug \
#    Install PHP extensions
    && docker-php-ext-install -j${NPROC} $phpModules \
    && for ext in $phpModules; do \
           rm -f /usr/local/etc/php/conf.d/docker-php-ext-$ext.ini; \
       done \
    && docker-php-source delete \
    && docker-php-ext-enable $phpModules

# Install composer and put binary into $PATH
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/ \
    && ln -s /usr/local/bin/composer.phar /usr/local/bin/composer

# Install Node.js & Yarn
RUN mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_VERSION.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
    && apt-get update \
    && apt-get install -y unzip nodejs build-essential libimagequant-dev \
    && corepack enable \
    && yarn global add pngquant-bin jpegtran-bin cwebp-bin optipng-bin \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false -o APT::AutoRemove::SuggestsImportant=false $buildDeps \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY etc/php/conf.d /usr/local/etc/php/conf.d
COPY msmtprc /etc/
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["php", "-a"]
