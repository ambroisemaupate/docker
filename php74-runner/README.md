# Gitlab/Travis CI PHP 7.4 runner
## For building PHP images and testing

**Inspired by https://github.com/TetraWeb/docker**

## Work in progress

So following extensions cannot be installed, compilation fails :

- enchant

## Build locally

```bash
DOCKER_REPO="roadiz/php74-runner" bash ./hooks/build
```
