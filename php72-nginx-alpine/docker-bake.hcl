variable "REGISTRY" {
    default = "roadiz/php72-nginx-alpine"
}

group "default" {
    targets = ["php72-nginx-alpine"]
}

target "php72-nginx-alpine" {
    platforms = ["linux/arm64/v8", "linux/amd64"]
    context = "."
    dockerfile = "Dockerfile"
    tags = ["${REGISTRY}:latest"]
}
