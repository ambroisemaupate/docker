variable "REGISTRY" {
    default = "roadiz/php82-runner"
}

group "default" {
    targets = ["php82-runner"]
}

target "php82-runner" {
    name = "php82-runner-node-${node}"
    platforms = ["linux/amd64"]
    context = "."
    dockerfile = "Dockerfile"
    matrix = {
        # "latest" uses Dockerfile default NODE_VERSION
        node = ["latest", "20", "18", "16", "14"]
    }
    args = {
        NODE_VERSION = node == "latest" ? null : node
    }
    tags = [node == "latest" ? "${REGISTRY}:latest" : "${REGISTRY}:node-${node}"]
}
