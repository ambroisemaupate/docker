# Gitlab/Travis CI PHP 8.3 runner
## For building PHP images and testing

This image is deprecated, please use `roadiz/php-runner:8.3.17-bookworm` instead.

---

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
DOCKER_REPO="roadiz/php83-runner" bash ./hooks/build
```
