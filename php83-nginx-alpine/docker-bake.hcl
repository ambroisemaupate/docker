variable "REGISTRY" {
    default = "roadiz/php83-nginx-alpine"
}

group "default" {
    targets = ["php83-nginx-alpine"]
}

target "php83-nginx-alpine" {
    platforms = ["linux/arm64/v8", "linux/amd64"]
    context = "."
    dockerfile = "Dockerfile"
    tags = ["${REGISTRY}:latest"]
}
