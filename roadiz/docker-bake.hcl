variable "REGISTRIES" {
    default = ["ambroisemaupate/roadiz", "roadiz/roadiz"]
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
        PHP_VERSION = "7.2"
        # Remi Collet's security backports, including CVE-2026-109618 and CVE-2026-109619
        PHP_FIX_BASE = "php-7.2.34"
        PHP_FIX_COMMIT = "28cff42ed5a39f88ddf5db7285607d88df697844"
    }
    tags = flatten([for r in REGISTRIES : ["${r}:php72", "${r}:php7.2", "${r}:latest"]])
}

target "php74" {
    inherits = ["_common"]
    args = {
        PHP_VERSION = "7.4"
        # Official php-src backport of CVE-2026-109618 and CVE-2026-109619 (PHP-7.4-CVE-2026-109618-109619)
        PHP_FIX_REPO = "https://github.com/php/php-src.git"
        PHP_FIX_BASE = "004cb827501d1ddaf98daacb185a53e0816f78a7"
        PHP_FIX_COMMIT = "712e60f9edfd03f0960fc4fc3c2c375f42b90aa2"
    }
    tags = flatten([for r in REGISTRIES : ["${r}:php74", "${r}:php7.4"]])
}
