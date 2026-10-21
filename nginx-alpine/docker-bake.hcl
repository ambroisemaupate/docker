variable "REGISTRY" {
    default = "roadiz/nginx-alpine"
}

group "default" {
    targets = ["nginx-alpine"]
}

target "nginx-alpine" {
    platforms = ["linux/arm64/v8", "linux/amd64"]
    context = "."
    dockerfile = "Dockerfile"
    tags = ["${REGISTRY}:latest"]
}
