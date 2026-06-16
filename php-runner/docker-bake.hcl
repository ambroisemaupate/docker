variable "REGISTRY" {
    default = "roadiz/php-runner"
}

variable "EXTENSIONS" {
    default = "amqp apcu bcmath bz2 calendar dba exif gd gettext gmp imap intl ldap mysqli opcache pcntl pcov pdo pdo_dblib pdo_mysql pdo_pgsql pgsql pspell shmop snmp soap tidy xsl zip redis-6.3.0"
}

target "runner" {
    target = "php-runner"
    name = "runner-${replace(item.version, ".", "-")}-${item.distrib}"
    platforms = ["linux/amd64"]
    matrix = {
        item = [
            {
                version = "8.1.34",
                shortVersion = "8.1",
                distrib = "bookworm",
                extensions = "${EXTENSIONS}"
            },
            {
                version = "8.2.31",
                shortVersion = "8.2",
                distrib = "bookworm",
                extensions = "${EXTENSIONS}"
            },
            {
                version = "8.3.31",
                shortVersion = "8.3",
                distrib = "bookworm",
                extensions = "${EXTENSIONS}"
            },
            {
                version = "8.4.22",
                shortVersion = "8.4",
                distrib = "bookworm",
                extensions = "${EXTENSIONS}"
            },
            {
                version = "8.5.7",
                shortVersion = "8.5",
                distrib = "trixie",
                # https://github.com/php-amqp/php-amqp/issues/600
                extensions = "bcmath bz2 calendar dba exif gd gettext gmp imap intl ldap mysqli opcache pcntl pcov pdo pdo_dblib pdo_mysql pdo_pgsql pgsql pspell shmop snmp soap tidy xsl zip redis-6.3.0"
            }
        ]
    }
    args = {
        PHP_VERSION = "${item.version}"
        DISTRIB = "${item.distrib}"
        EXTENSIONS = "${item.extensions}"
    }
    context = "."
    dockerfile = "Dockerfile"
    tags = [
        "${REGISTRY}:${item.version}-${item.distrib}",
        "${REGISTRY}:${item.shortVersion}-${item.distrib}",
        "${REGISTRY}:${item.shortVersion}"
    ]
}
