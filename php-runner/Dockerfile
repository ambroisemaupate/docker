ARG PHP_VERSION=8.4.4
ARG DISTRIB="bookworm"
ARG COMPOSER_VERSION=2.9.2
ARG UID=1000
ARG GID=1000
ARG EXTENSIONS="amqp apcu bcmath bz2 calendar dba exif gd gettext gmp imap intl ldap mysqli opcache pcntl pdo pdo_dblib pdo_mysql pdo_pgsql pgsql pspell shmop snmp soap tidy xsl redis-6.3.0"

FROM php:${PHP_VERSION}-cli-${DISTRIB} AS php-runner
LABEL org.opencontainers.image.authors="Ambroise Maupate <ambroise@rezo-zero.com>"

ARG UID
ARG GID
ARG COMPOSER_VERSION
ARG EXTENSIONS

ENV TIMEZONE="Europe/Paris"

SHELL ["/bin/bash", "-e", "-o", "pipefail", "-c"]

# Install PIE (PHP Installer for Extensions)
COPY --from=ghcr.io/php/pie:bin /pie /usr/bin/pie

RUN <<EOF
apt-get --quiet update
apt-get --quiet --yes --purge --autoremove upgrade
# Packages - System
apt-get --quiet --yes --no-install-recommends --verbose-versions install \
    less \
    sudo \
    git
rm -rf /var/lib/apt/lists/*

# User
addgroup --gid ${GID} php
adduser --home /home/php --shell /bin/bash --uid ${UID} --gecos php --ingroup php --disabled-password php
echo "php ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/php

# Php extensions
curl -sSLf  https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions \
    --output /usr/local/bin/install-php-extensions
chmod +x /usr/local/bin/install-php-extensions
install-php-extensions ${EXTENSIONS}

# Required for PHPUnit coverage reports
pie install xdebug/xdebug
EOF

COPY --link etc/php/conf.d /usr/local/etc/php/conf.d
COPY --link entrypoint.sh /entrypoint.sh

RUN ln -sf ${PHP_INI_DIR}/php.ini-development ${PHP_INI_DIR}/php.ini

WORKDIR /app

ENTRYPOINT ["/entrypoint.sh"]
CMD ["php", "-a"]
