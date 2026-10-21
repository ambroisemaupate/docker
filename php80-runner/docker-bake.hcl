variable "REGISTRY" {
    default = "roadiz/php80-runner"
}

group "default" {
    targets = ["php80-runner"]
}

target "php80-runner" {
    name = "php80-runner-node-${node}"
    platforms = ["linux/amd64"]
    context = "."
    dockerfile = "Dockerfile"
    matrix = {
        # "latest" uses Dockerfile default NODE_VERSION
        node = ["latest", "18", "16", "14"]
    }
    args = {
        NODE_VERSION = node == "latest" ? null : node
    }
    tags = [node == "latest" ? "${REGISTRY}:latest" : "${REGISTRY}:node-${node}"]
}
