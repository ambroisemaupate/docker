variable "REGISTRY" {
    default = "roadiz/php83-runner"
}

group "default" {
    targets = ["php83-runner"]
}

target "php83-runner" {
    name = "php83-runner-node-${node}"
    platforms = ["linux/amd64"]
    context = "."
    dockerfile = "Dockerfile"
    matrix = {
        # "latest" uses Dockerfile default NODE_VERSION
        node = ["latest", "20", "18", "16"]
    }
    args = {
        NODE_VERSION = node == "latest" ? null : node
    }
    tags = [node == "latest" ? "${REGISTRY}:latest" : "${REGISTRY}:node-${node}"]
}
