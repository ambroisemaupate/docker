variable "REGISTRY" {
    default = "roadiz/php73-nginx-alpine"
}

group "default" {
    targets = ["php73-nginx-alpine"]
}

target "php73-nginx-alpine" {
    platforms = ["linux/arm64/v8", "linux/amd64"]
    context = "."
    dockerfile = "Dockerfile"
    tags = ["${REGISTRY}:latest"]
}
