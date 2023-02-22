buildx:
	docker buildx build --push --platform linux/arm64/v8,linux/amd64 --tag roadiz/php82-nginx-alpine:latest .

amd64:
	docker buildx build --push --platform linux/amd64 --tag roadiz/php82-nginx-alpine:latest .

arm64:
	docker buildx build --push --platform linux/arm64/v8 --tag roadiz/php82-nginx-alpine:latest .
