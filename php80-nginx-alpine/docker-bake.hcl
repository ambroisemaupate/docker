variable "REGISTRY" {
    default = "roadiz/php80-nginx-alpine"
}

group "default" {
    targets = ["php80-nginx-alpine"]
}

target "php80-nginx-alpine" {
    name = "php80-nginx-alpine-${replace(version, ".", "-")}"
    platforms = ["linux/arm64/v8", "linux/amd64"]
    context = "."
    dockerfile = "Dockerfile"
    matrix = {
        # "8.0" resolves to the latest PHP 8.0 release
        version = ["8.0", "8.0.30", "8.0.29", "8.0.28"]
    }
    args = {
        PHP_VERSION = version
    }
    tags = [version == "8.0" ? "${REGISTRY}:latest" : "${REGISTRY}:${version}"]
}
