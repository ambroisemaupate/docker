variable "REGISTRY" {
    default = "roadiz/php82-fpm-alpine"
}

group "default" {
    targets = ["php82-fpm-alpine"]
}

target "php82-fpm-alpine" {
    platforms = ["linux/arm64/v8", "linux/amd64"]
    context = "."
    dockerfile = "Dockerfile"
    tags = ["${REGISTRY}:latest"]
}
