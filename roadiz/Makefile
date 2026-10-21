buildx:
	docker buildx bake --pull --push

amd64:
	docker buildx bake --pull --push --set '*.platform=linux/amd64'

arm64:
	docker buildx bake --pull --push --set '*.platform=linux/arm64/v8'

load:
	docker buildx bake --load --set '*.platform=linux/amd64'

test:
	docker buildx bake

php72:
	docker buildx bake --pull --push php72

php74:
	docker buildx bake --pull --push php74
