variable "REGISTRY" {
    default = "roadiz/php81-fpm-alpine"
}

group "default" {
    targets = ["php81-fpm-alpine"]
}

target "php81-fpm-alpine" {
    platforms = ["linux/arm64/v8", "linux/amd64"]
    context = "."
    dockerfile = "Dockerfile"
    tags = ["${REGISTRY}:latest"]
}
