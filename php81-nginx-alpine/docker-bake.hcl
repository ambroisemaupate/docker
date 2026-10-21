variable "REGISTRY" {
    default = "roadiz/php81-nginx-alpine"
}

group "default" {
    targets = ["php81-nginx-alpine"]
}

target "php81-nginx-alpine" {
    platforms = ["linux/arm64/v8", "linux/amd64"]
    context = "."
    dockerfile = "Dockerfile"
    tags = ["${REGISTRY}:latest"]
}
