# Gitlab/Travis CI PHP 8.1 runner
## For building PHP images and testing

**Inspired by https://github.com/TetraWeb/docker**

## Work in progress

So following extensions cannot be installed, compilation fails (not yet ready for PHP 8+) :

- amqp
- igbinary
- mongodb
- redis
- enchant

## Build locally

```bash
DOCKER_REPO="roadiz/php81-runner" bash ./hooks/build
```
