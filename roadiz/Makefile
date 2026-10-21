IMAGES = ambroisemaupate/roadiz roadiz/roadiz
PLATFORMS = linux/arm64/v8,linux/amd64

buildx: php72 php74

# latest stays on PHP 7.2 for backward compatibility
php72:
	docker buildx build --pull --push --platform $(PLATFORMS) --build-arg PHP_VERSION=7.2 $(foreach i,$(IMAGES),--tag $(i):php72 --tag $(i):latest) .

php74:
	docker buildx build --pull --push --platform $(PLATFORMS) --build-arg PHP_VERSION=7.4 $(foreach i,$(IMAGES),--tag $(i):php74) .
