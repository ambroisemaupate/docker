# Gitlab CI / Github Actions PHP runner image

This is image is a replacement for:
- roadiz/php80-runner
- roadiz/php81-runner
- roadiz/php82-runner
- roadiz/php83-runner

It does not include NodeJS runtime anymore.

## Available PHP extensions

- composer
- amqp 
- apcu 
- bcmath 
- bz2 
- calendar 
- dba 
- exif 
- gd 
- gettext 
- gmp 
- imap 
- intl 
- ldap 
- mysqli 
- opcache 
- pcntl 
- pdo 
- pdo_dblib 
- pdo_mysql 
- pdo_pgsql 
- pgsql 
- pspell 
- redis 
- shmop 
- snmp 
- soap 
- tidy 
- xdebug 
- xsl 
- zip 
- redis

## Building images

```shell
# Display all available targets
docker buildx bake --print runner

# Build all targets and push to Docker Hub
docker buildx bake runner --push
```
## Add your Gitlab Composer deploy token

Provide these environment variables to authorize Composer to download your private repositories from a Gitlab instance:

```shell
GITLAB_DOMAIN=gitlab.com
COMPOSER_DEPLOY_TOKEN_USER=gitlab-ci-token
COMPOSER_DEPLOY_TOKEN=your-token
```

Then this image will execute `composer config --global gitlab-token.${GITLAB_DOMAIN} ${COMPOSER_DEPLOY_TOKEN_USER} ${COMPOSER_DEPLOY_TOKEN}` before running any command.

## Add your Github Composer deploy token

Provide these environment variables to authorize Composer to download your private repositories from a Github:

```shell
COMPOSER_GITHUB=your-token
```

Then this image will execute `composer config --global github-oauth.github.com "$COMPOSER_GITHUB"` before running any command.

## Setting timezone

You can set the php timezone with direct setting it in php.ini within your `.gitlab-ci.yml` like:

```shell
before_script:
  - echo "date.timezone = 'Europe/Paris'" > /usr/local/etc/php/conf.d/timezone.ini
```
