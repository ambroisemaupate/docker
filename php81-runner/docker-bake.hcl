variable "REGISTRY" {
    default = "roadiz/php81-runner"
}

group "default" {
    targets = ["php81-runner"]
}

target "php81-runner" {
    name = "php81-runner-node-${node}"
    platforms = ["linux/amd64"]
    context = "."
    dockerfile = "Dockerfile"
    matrix = {
        # "latest" uses Dockerfile default NODE_VERSION
        node = ["latest", "20", "18", "16", "14", "12"]
    }
    args = {
        NODE_VERSION = node == "latest" ? null : node
    }
    tags = [node == "latest" ? "${REGISTRY}:latest" : "${REGISTRY}:node-${node}"]
}
