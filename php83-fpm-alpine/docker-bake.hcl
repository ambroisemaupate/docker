variable "REGISTRY" {
    default = "roadiz/php83-fpm-alpine"
}

group "default" {
    targets = ["php83-fpm-alpine"]
}

target "php83-fpm-alpine" {
    platforms = ["linux/arm64/v8", "linux/amd64"]
    context = "."
    dockerfile = "Dockerfile"
    tags = ["${REGISTRY}:latest"]
}
