# roadiz/php83-fpm-alpine

**Base *php-fpm* image for running Roadiz app, cron-jobs and workers.**

This image does not provide *Nginx* server, but it includes *dcron* and many image processing binaries. 
It listens on port `9000` and is meant to be used with a separate *Nginx* container.

Make sure to use a `.dockerignore` at your project root not to include any existing
cache files or build-time vendors (node_modules).

Before building your project Docker image make sure to prepare your project sources:

- `composer install -o`
- Add any development or user files paths to the `.dockerignore`

## One container = one process

This image is designed to run only one process at a time. If your project needs to run _cron jobs_ or workers (_Symfony Messenger_), you should use a separate container for each process and override container entrypoint (only main app container should launch `docker-php-entrypoint`).

## Image build example

Create a `docker/php-fpm-alpine/Dockerfile` file in your Roadiz / Symfony project.

You can customize the image by overriding the following files:
- `docker/php-fpm-alpine/php.prod.ini`
- `docker/php-fpm-alpine/crontab.txt`
- `docker/php-fpm-alpine/docker-php-entrypoint`

```Dockerfile
# File: docker/php-fpm-alpine/Dockerfile
FROM roadiz/php83-fpm-alpine:latest
MAINTAINER Ambroise Maupate <ambroise@rezo-zero.com>
ARG USER_UID=1000

RUN usermod -u ${USER_UID} www-data \
    && groupmod -g ${USER_UID} www-data

# Copy custom configuration files
COPY docker/php-fpm-alpine/php.prod.ini /usr/local/etc/php/php.ini
COPY docker/php-fpm-alpine/crontab.txt /crontab.txt
COPY docker/php-fpm-alpine/docker-php-entrypoint /usr/local/bin/docker-php-entrypoint

# Copy your project files
COPY --chown=www-data:www-data . /var/www/html/

RUN ln -s /var/www/html/bin/console /usr/local/bin/console \
    && /usr/bin/crontab -u www-data /crontab.txt \
    && chmod +x /usr/local/bin/docker-php-entrypoint \
    && chown -R www-data:www-data /var/www/html/

# Define persistent data volumes directories
VOLUME /var/www/html/config/jwt \
       /var/www/html/config/secrets \
       /var/www/html/public/files \
       /var/www/html/public/assets \
       /var/www/html/var/files \
       /var/www/html/var/secret
```

## Use cases

- Main app container with default entrypoint with `php-fpm` 
```yaml
app:
    build:
        dockerfile: ./docker/php-fpm-alpine
        context: .
        args:
            USER_UID: ${USER_UID}
    restart: always
    depends_on:
        - db
        - redis
    volumes:
        # Provide named volumes for persistent data
        - app_jwt_data:/var/www/html/config/jwt
        - app_file_data:/var/www/html/public/files
        - app_assets_data:/var/www/html/public/assets
        - app_private_file_data:/var/www/html/var/files
        - app_secret_data:/var/www/html/config/secrets
    networks:
        - default
    environment:
        APP_ENV: ${APP_ENV}
        APP_RUNTIME_ENV: ${APP_RUNTIME_ENV}
        APP_DEBUG: ${APP_DEBUG}
```
- `crontab` support for scheduled tasks by **overriding container entrypoint**:
```yaml
cron:
    extends: app
    init: true
    entrypoint: [ "crond", "-f", "-L", "15" ]
    restart: always
```
- _Symfony Messenger_ worker by **overriding container entrypoint**:
```yaml
worker:
    extends: app
    deploy:
        replicas: 1
    entrypoint: [ "php", "/var/www/html/bin/console", "messenger:consume", "async", "--time-limit=1800" ]
    restart: always
```
