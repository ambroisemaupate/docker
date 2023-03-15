buildx:
	docker buildx build --push --platform linux/arm64/v8,linux/amd64 --tag roadiz/php81-fpm-alpine:latest .

amd64:
	docker buildx build --push --platform linux/amd64 --tag roadiz/php81-fpm-alpine:latest .

arm64:
	docker buildx build --push --platform linux/arm64/v8 --tag roadiz/php81-fpm-alpine:latest .
