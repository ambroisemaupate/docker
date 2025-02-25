# Gitlab/Travis CI PHP 8.1 runner
## For building PHP images and testing

This image is deprecated, please use `roadiz/php-runner:8.1.31-bullseye` instead.

---

**Inspired by https://github.com/TetraWeb/docker**

## Work in progress

So following extensions cannot be installed, compilation fails (not yet ready for PHP 8+) :

- igbinary
- mongodb
- enchant

## Build locally

```bash
DOCKER_REPO="roadiz/php81-runner" bash ./hooks/build
```
