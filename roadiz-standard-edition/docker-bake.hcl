variable "REGISTRIES" {
    default = ["ambroisemaupate/roadiz-standard-edition", "roadiz/standard-edition"]
}

group "default" {
    targets = ["php72", "php74"]
}

target "_common" {
    platforms = ["linux/arm64/v8", "linux/amd64"]
    context = "."
    dockerfile = "Dockerfile"
}

# latest stays on PHP 7.2 for backward compatibility
target "php72" {
    inherits = ["_common"]
    args = {
        ROADIZ_TAG = "php7.2"
    }
    tags = flatten([for r in REGISTRIES : ["${r}:php72", "${r}:php7.2", "${r}:latest"]])
}

target "php74" {
    inherits = ["_common"]
    args = {
        ROADIZ_TAG = "php7.4"
    }
    tags = flatten([for r in REGISTRIES : ["${r}:php74", "${r}:php7.4"]])
}
