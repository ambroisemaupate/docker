#!/bin/bash
set -e

# Provide github token if you are using composer a lot in non-interactive mode
# Otherwise one day it will get stuck with request for authorization
# https://github.com/settings/tokens
if [[ ! -z "$COMPOSER_GITHUB" ]]
then
  echo "Installing Github token"
  composer config --global github-oauth.github.com "$COMPOSER_GITHUB"
fi

# Provide gitlab token if you are using composer a lot in non-interactive mode
# Otherwise one day it will get stuck with request for authorization
# https://github.com/settings/tokens
if [[ ! -z "$GITLAB_DOMAIN" ]]
then
  echo "Installing Gitlab token for domain ${GITLAB_DOMAIN}"
  composer config --global gitlab-token.${GITLAB_DOMAIN} ${COMPOSER_DEPLOY_TOKEN_USER} ${COMPOSER_DEPLOY_TOKEN}
fi

#
# If $TIMEZONE variable is passed to the image - it will set system timezone
# and php.ini date.timezone value as well
# Otherwise the default system Etc/UTC timezone will be used
#
# Also you can set the php timezone with direct setting it in php.ini
# within your .gitlab-ci.yml like
# before_script:
# - echo "America/New_York" > /usr/local/etc/php/conf.d/timezone.ini
if [[ ! -z "$TIMEZONE" ]]
then
  echo "${TIMEZONE}" > /etc/timezone
  echo "date.timezone=${TIMEZONE}" > /usr/local/etc/php/conf.d/timezone.ini
fi

# print PHP version
php --version
echo "PHP timezone: $(php -r 'echo date_default_timezone_get();')"

exec "$@"
