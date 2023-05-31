FROM php:7.4-buster

ARG NODE_VERSION=12

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
        libpq-dev \
        libpspell-dev \
        librabbitmq-dev \
        libsasl2-dev \
        libsnmp-dev \
        libssl-dev \
        libtidy-dev \
        libxml2-dev \
        libxslt1-dev \
        zlib1g-dev \
        libonig-dev \
        libwebp-dev \
    " \
    && runDeps=" \
        libc-client2007e \
        libfreetype6 \
        libicu63 \
        libjpeg62-turbo \
        libmcrypt4 \
        libpng-dev \
        libzip-dev \
        libpng16-16 \
        libpq5 \
        libsybdb5 \
        libtidy5deb1 \
        libx11-6 \
        libxslt1.1 \
        snmp \
        gnupg \
    " \
    && phpModules=" \
        bcmath \
        bz2 \
        calendar \
        dba \
        exif \
        ftp \
        gd \
        gettext \
        gmp \
        imap \
        intl \
        ldap \
        mbstring \
        mysqli \
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
        xmlrpc \
        xsl \
        zip \
    " \
    && NPROC=$(getconf _NPROCESSORS_ONLN) \
    #&& echo "deb http://security.debian.org/debian-security buster main contrib non-free" > /etc/apt/sources.list.d/additional.list \
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
#    Install PHP extensions
    && docker-php-ext-install -j${NPROC} $phpModules \
    && printf "\n" | pecl install amqp \
    && pecl install igbinary \
    && pecl install mongodb \
    && pecl install redis \
    && for ext in $phpModules; do \
           rm -f /usr/local/etc/php/conf.d/docker-php-ext-$ext.ini; \
       done \
    && docker-php-source delete \
    && docker-php-ext-enable $phpModules

# Install composer and put binary into $PATH
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/ \
    && ln -s /usr/local/bin/composer.phar /usr/local/bin/composer

# Install phpunit and put binary into $PATH
RUN curl -sSLo phpunit.phar https://phar.phpunit.de/phpunit.phar \
    && chmod 755 phpunit.phar \
    && mv phpunit.phar /usr/local/bin/ \
    && ln -s /usr/local/bin/phpunit.phar /usr/local/bin/phpunit

# Install PHP Code sniffer
RUN curl -OL https://squizlabs.github.io/PHP_CodeSniffer/phpcs.phar \
    && chmod 755 phpcs.phar \
    && mv phpcs.phar /usr/local/bin/ \
    && ln -s /usr/local/bin/phpcs.phar /usr/local/bin/phpcs \
    && curl -OL https://squizlabs.github.io/PHP_CodeSniffer/phpcbf.phar \
    && chmod 755 phpcbf.phar \
    && mv phpcbf.phar /usr/local/bin/ \
    && ln -s /usr/local/bin/phpcbf.phar /usr/local/bin/phpcbf

# Install Node.js & Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && curl -sL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - \
    && apt-get install -y unzip nodejs build-essential yarn libimagequant-dev \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false -o APT::AutoRemove::SuggestsImportant=false $buildDeps \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY etc/php/conf.d /usr/local/etc/php/conf.d
COPY msmtprc /etc/
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["php", "-a"]
