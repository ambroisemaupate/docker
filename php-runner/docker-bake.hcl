variable "REGISTRY" {
    default = "roadiz/php-runner"
}

variable "EXTENSIONS" {
    default = "php-amqp/php-amqp@v2.2.0 krakjoe/apcu@v5.1.28 bcmath bz2 calendar dba exif gd gettext gmp imap intl ldap mysqli opcache pcntl krakjoe/pcov@v1.0.12 pdo pdo_dblib pdo_mysql pdo_pgsql pgsql pspell shmop snmp soap tidy xsl zip"
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
                version = "8.2.35",
                shortVersion = "8.2",
                distrib = "bookworm",
                extensions = "${EXTENSIONS}"
            },
            {
                version = "8.3.36",
                shortVersion = "8.3",
                distrib = "bookworm",
                extensions = "${EXTENSIONS}"
            },
            {
                version = "8.4.27",
                shortVersion = "8.4",
                distrib = "bookworm",
                extensions = replace(replace(EXTENSIONS, " imap ", " php/pecl-mail-imap@1.0.3 "), " pspell ", " php/pecl-text-pspell@1.0.1 ")
            },
            {
                version = "8.5.12",
                shortVersion = "8.5",
                distrib = "trixie",
                # https://github.com/php-amqp/php-amqp/issues/600
                extensions = "bcmath bz2 calendar dba exif gd gettext gmp php/pecl-mail-imap@1.0.3 intl ldap mysqli opcache pcntl krakjoe/pcov@v1.0.12 pdo pdo_dblib pdo_mysql pdo_pgsql pgsql php/pecl-text-pspell@1.0.1 shmop snmp soap tidy xsl zip"
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
