variable "REGISTRY" {
    default = "roadiz/php56-nginx-alpine"
}

group "default" {
    targets = ["php56-nginx-alpine"]
}

target "php56-nginx-alpine" {
    platforms = ["linux/amd64"]
    context = "."
    dockerfile = "Dockerfile"
    tags = ["${REGISTRY}:latest"]
}
