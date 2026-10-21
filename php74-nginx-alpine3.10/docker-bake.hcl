variable "REGISTRY" {
    default = "roadiz/php74-nginx-alpine3.10"
}

group "default" {
    targets = ["php74-nginx-alpine3-10"]
}

target "php74-nginx-alpine3-10" {
    platforms = ["linux/arm64/v8", "linux/amd64"]
    context = "."
    dockerfile = "Dockerfile"
    tags = ["${REGISTRY}:latest"]
}
