variable "REGISTRY" {
    default = "roadiz/php74-nginx-alpine"
}

group "default" {
    targets = ["php74-nginx-alpine"]
}

target "php74-nginx-alpine" {
    platforms = ["linux/arm64/v8", "linux/amd64"]
    context = "."
    dockerfile = "Dockerfile"
    tags = ["${REGISTRY}:latest"]
}
