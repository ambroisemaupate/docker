variable "REGISTRY" {
    default = "roadiz/php74-runner"
}

group "default" {
    targets = ["php74-runner"]
}

target "php74-runner" {
    name = "php74-runner-node-${node}"
    platforms = ["linux/amd64"]
    context = "."
    dockerfile = "Dockerfile"
    matrix = {
        # "latest" uses Dockerfile default NODE_VERSION
        node = ["latest", "18", "16", "14", "12", "10"]
    }
    args = {
        NODE_VERSION = node == "latest" ? null : node
    }
    tags = [node == "latest" ? "${REGISTRY}:latest" : "${REGISTRY}:node-${node}"]
}
