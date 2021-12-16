# roadiz/php81-nginx-alpine
**Base *php-fpm with nginx* image for building Roadiz sub-images.**    
**⚠️ For production only**

This image does not provide *Yarn*, and it is meant
to be extended for each of your projects. This image should be as light as possible
to be built with your website sources and vendor included.

Make sure to use a `.dockerignore` at your project root not to include any existing
cache files or build-time vendors (node_modules).

Before building your project image make sure to:

- `make`
- `composer update --no-dev`
- `composer dumpautoload -o -a`
- Copy any configuration needed at launch
- Add any development or user files paths to the `.dockerignore`

## Build example

Create a `Dockerfile` in your Roadiz project root.

```
FROM roadiz/php81-nginx-alpine:latest
MAINTAINER Ambroise Maupate <ambroise@rezo-zero.com>
ENV USER_UID=1000
ARG USER_UID=1000
ENV ROADIZ_ENV=prod

RUN usermod -u ${USER_UID} www-data \
    && groupmod -g ${USER_UID} www-data

COPY custom/location/crontab.txt /crontab.txt
COPY --chown=www-data:www-data . /var/www/html/
COPY --chown=www-data:www-data samples/index.php.sample /var/www/html/web/index.php
COPY --chown=www-data:www-data samples/preview.php.sample /var/www/html/web/preview.php
COPY --chown=www-data:www-data samples/clear_cache.php.sample /var/www/html/web/clear_cache.php

COPY custom/location/before_launch.sh /before_launch.sh

RUN /usr/bin/crontab -u www-data /crontab.txt && \
    chmod +x /before_launch.sh

VOLUME /var/www/html/files \
       /var/www/html/web/files \
       /var/www/html/app/logs  \
       /var/www/html/app/conf \
       /var/www/html/app/gen-src/GeneratedNodeSources \
       /var/www/html/app/gen-src/Proxies \
       /var/www/html/app/gen-src/Compiled

ENTRYPOINT exec /usr/bin/supervisord -n -c /etc/supervisord.conf
```

## Work in progress

So following extensions cannot be installed, compilation fails (not yet ready for PHP 8+) :

- amqp
- igbinary
- mongodb
- redis
