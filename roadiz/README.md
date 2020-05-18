# Roadiz docker-image

**Inherits ambroisemaupate/nginx-php**

This image will install:

* Git
* Cron (crontab)
* Composer

## ***Deprecated***
Use you own built *image* using *roadiz/php7.x-nginx-alpine* to avoid sources
manipulation inside your production containers.

## Environment variables

* `ROADIZ_BRANCH` *master* or *develop*

## Docker dependencies

* A *ambroisemaupate/mariadb* container for its database:

```bash
# Create a volume for persisting DB data
docker volume create --name="my-roadiz_DBDATA"
# Create MariaDB container
docker run -t -d --name="my-roadiz-mariadb" \
              -v my-roadiz_DBDATA:/data \
              --env="MARIADB_USER=foo" \
              --env="MARIADB_PASS=bar" \
              ambroisemaupate/mariadb
```

## Run a new Roadiz container

```bash
# Launch me
docker run -d --name="my-roadiz" --hostname="my-roadiz" -p 80:80 \
              --env ROADIZ_BRANCH=master \
              -v my-roadiz_DATA:/data \
              --link="my-roadiz-mariadb:mariadb" ambroisemaupate/roadiz
```

Your database credentials will be:

* Host: `mariadb`
* User: `foo`
* Password: `bar`
* Database: `foo`

## Using Roadiz CLI commands

You can of-course use Roadiz `bin/roadiz` commands to manage your website
parameters and cache in CLI. But before doing anything, pay attention to
do it as the `core` user, **NOT** the `root` user.

```bash
# On your Docker host
docker exec -ti --user=core my-roadiz bash

cd /data/http
# For example clear Roadiz app cache
bin/roadiz cache:clear --env=prod
```

## Using a deploy/access key for Github/Gitlab

This docker image is configured to look for your *SSH* public key in `/data/secure/ssh`.
Pay attention to generate you *ssh-key* as `core` user: `su -s /bin/bash core`
before doing anything in your `/data` folder.

```bash
# On your Docker host
docker exec -ti --user=core my-roadiz bash

# On your docker container…
# Add the generated /data/secure/ssh/id_rsa.pub key to your Github/Gitlab account
cat /data/secure/ssh/id_rsa.pub

# Clone your custom theme
cd /data/http/themes
git clone git@github.com:private-account/custom-theme.git CustomTheme
# Install your theme composer dependencies (if any)
cd /data/http
composer update --no-dev -o
```

## OPCache

**Be careful**, PHP is configured with **OPCache** and a very aggressive PHP class cache: `opcache.revalidate_freq=60`.
If you are modifying some php files directly on your container, *restart your container*
or add `fastcgi_param PHP_VALUE "opcache.revalidate_freq=0";` line in your fastcgi Nginx config.

Normally *dev.php*, *install.php* and *preview.php* entry points are configured to revalidate cache at
each request.

## Clear cache

You’ll be able to clear cache only from localhost using `curl`.

```bash
# On your Docker host
docker exec -ti --user=core my-roadiz bash

curl http://localhost/clear_cache.php
```

## Compose example

In a blank folder named `my-roadiz/` create a `docker-compose.yml` file
with the following content:

```yaml
version: '2'
services:
  MAIN:
    hostname: my-roadiz
    image: ambroisemaupate/roadiz
    environment:
      ROADIZ_BRANCH: develop
    ports:
      - "8080:80"
    volumes:
      - DATA:/data
    links:
      - DB:mariadb
    depends_on:
      - DB
  DB:
    image: ambroisemaupate/mariadb
    environment:
      MARIADB_USER: "roadiz_test"
      MARIADB_PASS: "pass0rd"
    volumes:
      - DBDATA:/data
  SSH:
    image: ambroisemaupate/light-ssh
    environment:
      PASS: "roadiz_test"
    volumes:
      - DATA:/data
    links:
      - DB:mariadb
    depends_on:
      - DB
    ports:
      - "22/tcp"
volumes:
  DATA:
  DBDATA:
```

Then launch your container network with `docker-compose up -d`. This will create:

- `my-roadiz_MAIN_1` container
- `my-roadiz_DB_1` container
- `my-roadiz_SSH_1` container
- `my-roadiz_DATA` volume
- `my-roadiz_DBDATA` volume
