# Roadiz docker-image

**Based on ambroisemaupate/nginx-php**

This image will install:

* Git
* Cron (crontab)
* Composer

## Environment variables

* `ROADIZ_BRANCH` *master* or *develop*

## Docker dependencies

Roadiz image will work with:

* A *maxexcloo/data* container for volume handling:

```bash
docker run -d --name="my-roadiz_DATA" maxexcloo/data
```

* A *maxexcloo/mariadb* container for its database:

```bash
docker run -t -d --name="my-roadiz-mariadb" \
              --env="MARIADB_USER=foo" --env="MARIADB_PASS=bar" \
              --env="MARIADB_DB=foo" maxexcloo/mariadb
```

## Run a new Roadiz container

```bash
# Launch me
docker run -t -d --name="my-roadiz" -p 80:80 \
              --env ROADIZ_BRANCH=master \
              --volumes-from="my-roadiz_DATA" \
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
docker exec -ti --user=core my-roadiz /bin/bash

# Now you’re on your Docker container
# If you need to use a CLI editor like nano
# you’ll need to set TERM environment var
export TERM=xterm

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
docker exec -ti --user=core my-roadiz /bin/bash

# On your docker container…
# Generate public/private keys
ssh-keygen -t rsa -b 2048 -N '' -f /data/secure/ssh/id_rsa \
           -C "Deploy key ($HOSTNAME) for private repository"
# Add the generated /data/secure/ssh/id_rsa.pub key to your Github/Gitlab account

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
