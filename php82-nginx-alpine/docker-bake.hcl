variable "REGISTRY" {
    default = "roadiz/php82-nginx-alpine"
}

group "default" {
    targets = ["php82-nginx-alpine"]
}

target "php82-nginx-alpine" {
    platforms = ["linux/arm64/v8", "linux/amd64"]
    context = "."
    dockerfile = "Dockerfile"
    tags = ["${REGISTRY}:latest"]
}
