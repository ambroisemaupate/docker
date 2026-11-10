variable "REGISTRY" {
    default = "roadiz/php-runner"
}

variable "EXTENSIONS" {
    default = "php-amqp/php-amqp@v2.2.0 krakjoe/apcu@v5.1.28 bcmath bz2 calendar dba exif gd gettext gmp imagick imap intl ldap mysqli opcache pcntl krakjoe/pcov@v1.0.12 pdo pdo_dblib pdo_mysql pdo_pgsql pgsql pspell shmop snmp soap tidy xsl zip"
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
                extensions = "bcmath bz2 calendar dba exif gd gettext gmp imagick php/pecl-mail-imap@1.0.3 intl ldap mysqli opcache pcntl krakjoe/pcov@v1.0.12 pdo pdo_dblib pdo_mysql pdo_pgsql pgsql php/pecl-text-pspell@1.0.1 shmop snmp soap tidy xsl zip"
            },
            {
                # Release candidate: no moving 8.6 tag until GA
                version = "8.6.0RC5",
                shortVersion = "8.6-rc",
                distrib = "trixie",
                # imap, pcov and pspell do not build on 8.6 yet, imagick, Xdebug and redis from pre-releases
                xdebug = "3.6.0alpha1",
                # phpredis develop, 6.3.0 does not build on 8.6
                redis = "7c186d94a5fbabbee14f79cdcc44398feb80b55f",
                extensions = "bcmath bz2 calendar dba exif gd gettext gmp Imagick/imagick@55ed2e9fda264395636a2e27e51f31673f5566ab intl ldap mysqli opcache pcntl pdo pdo_dblib pdo_mysql pdo_pgsql pgsql shmop snmp soap tidy xsl zip"
            }
        ]
    }
    args = {
        PHP_VERSION = "${item.version}"
        DISTRIB = "${item.distrib}"
        EXTENSIONS = "${item.extensions}"
        XDEBUG_VERSION = lookup(item, "xdebug", "3.5.3")
        REDIS_VERSION = lookup(item, "redis", "6.3.0")
    }
    context = "."
    dockerfile = "Dockerfile"
    tags = [
        "${REGISTRY}:${item.version}-${item.distrib}",
        "${REGISTRY}:${item.shortVersion}-${item.distrib}",
        "${REGISTRY}:${item.shortVersion}"
    ]
}
