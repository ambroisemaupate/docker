# roadiz/php74-apache
**Base *php-fpm with Apache* image for building Roadiz sub-images.**    
**⚠️ For production only**

This image does not provide *Yarn* and it is meant
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
FROM roadiz/php74-apache
MAINTAINER Ambroise Maupate <ambroise@rezo-zero.com>

ARG USER_UID=1000
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV ROADIZ_ENV=dev
ENV USE_APP_CACHE=0

# Override php vars
# ADD php.ini /usr/local/etc/php/php.ini

# You need to provide your Apache virtual host conf file…
ADD default.conf /etc/apache2/sites-enabled/000-default.conf

VOLUME /var/www/html
WORKDIR /var/www/html

RUN echo "USER_UID: ${USER_UID}\n" \
    && a2enmod headers expires rewrite \
    && usermod -u ${USER_UID} www-data \
    && groupmod -g ${USER_UID} www-data \
    && chown -R www-data:www-data /var/www/html/
```

