buildx:
	docker buildx bake --pull --push

amd64:
	docker buildx bake --pull --push --set '*.platform=linux/amd64'

load:
	docker buildx bake --load --set '*.platform=linux/amd64'

test:
	docker buildx bake
