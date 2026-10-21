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
# Build and push latest and every node-* tag
make buildx
# Build a single Node version locally
docker buildx bake --load php81-runner-node-16
```
