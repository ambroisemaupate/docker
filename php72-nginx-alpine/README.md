# roadiz/php72-nginx-alpine
**Base *php-fpm with nginx* image for building Roadiz sub-images.**

This image does not provide any tools like *Composer* or *Yarn* and it is meant
to be extended for each of your projects. This image should be as light as possible
to be built with your web site sources and vendor included.

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
FROM roadiz/php72-nginx-alpine:latest
MAINTAINER Ambroise Maupate <ambroise@rezo-zero.com>

COPY . /var/www/html/
COPY samples/index.php.docker /var/www/html/web/index.php
COPY samples/preview.php.docker /var/www/html/web/preview.php
COPY samples/clear_cache.php.sample /var/www/html/web/clear_cache.php
VOLUME /var/www/html/files /var/www/html/web/files /var/www/html/app/logs /var/www/html/app/conf /var/www/html/app/gen-src/GeneratedNodeSources

RUN chown -R www-data:www-data /var/www/html/
ENTRYPOINT exec /usr/bin/supervisord -n -c /etc/supervisord.conf
```
