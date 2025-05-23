variable "REGISTRY" {
    default = "roadiz/php-runner"
}

target "runner" {
    target = "php-runner"
    name = "runner-${replace(item.version, ".", "-")}-${item.distrib}"
    platforms = ["linux/amd64"]
    matrix = {
        item = [
            {
                version = "8.0.30",
                distrib = "bullseye",
            },
            {
                version = "8.1.32",
                distrib = "bullseye",
            },
            {
                version = "8.2.28",
                distrib = "bullseye",
            },
            {
                version = "8.3.21",
                distrib = "bookworm",
            },
            {
                version = "8.4.7",
                distrib = "bookworm",
            }
        ]
    }
    args = {
        PHP_VERSION = "${item.version}"
        DISTRIB = "${item.distrib}"
    }
    context = "."
    dockerfile = "Dockerfile"
    tags = ["${REGISTRY}:${item.version}-${item.distrib}"]
}
