# roadiz/php81-fpm-alpine
**Base *php-fpm* image for building Roadiz sub-images.**    
**⚠️ For production only**

This image does not provide *Nginx* server. It listens on port `9000` and is meant to be used with a separate *Nginx* container.

It is meant to be extended for each of your projects. This image should be as light as possible
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
FROM roadiz/php81-fpm-alpine:latest
MAINTAINER Ambroise Maupate <ambroise@rezo-zero.com>
ENV USER_UID=1000
ARG USER_UID=1000

RUN usermod -u ${USER_UID} www-data \
    && groupmod -g ${USER_UID} www-data

COPY custom/location/crontab.txt /crontab.txt
COPY custom/location/before_launch.sh /before_launch.sh
# Copy your project sources
COPY --chown=www-data:www-data . /var/www/html/

RUN /usr/bin/crontab -u www-data /crontab.txt && \
    chmod +x /before_launch.sh

VOLUME /var/www/html/var/files \
       /var/www/html/public/files \
       /var/www/html/public/assets
```
