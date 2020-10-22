# Docker custom images

[![Build Status](https://travis-ci.org/ambroisemaupate/docker.svg?branch=master)](https://travis-ci.org/ambroisemaupate/docker)

This is a personal collection of *Docker* tools and images.

*debian*, *data*, *mariadb*, *nginx* and *nginx-php* are based on [Maxexcloo work](https://github.com/maxexcloo/Docker).

## Multi-arch builds

If your development workstation uses *ARM64* platform, you need to build Roadiz base images for this CPU  architecture.

Check if official images are providing these architectures: https://hub.docker.com/repository/docker/roadiz/php74-nginx-alpine/tags then if your *OS/ARCH* is not available you’ll need to build it. Notice that using *BuildX* with *QEMU* may take several minutes depending on your machine.

- Create a [BuildX](https://github.com/docker/buildx#building-with-buildx) environment
```
docker buildx create
docker buildx ls
```
- Use your new environment
```
docker buildx use xxxxxxx
```
- Build and push docker image for AMD64 and ARM64
```
# Login to hub.docker.com registry
docker login
# use buildx to build and push multiple platforms
docker buildx build \
--push \
--platform linux/arm64/v8,linux/amd64 --tag roadiz/php74-nginx-alpine:latest .
```
