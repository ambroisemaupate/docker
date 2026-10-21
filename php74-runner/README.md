# Gitlab/Travis CI PHP 7.4 runner
## For building PHP images and testing

**Inspired by https://github.com/TetraWeb/docker**

## Work in progress

So following extensions cannot be installed, compilation fails :

- enchant

## Build locally

```bash
# Build and push latest and every node-* tag
make buildx
# Build a single Node version locally
docker buildx bake --load php74-runner-node-12
```
