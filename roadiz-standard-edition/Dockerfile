# php7.2 (latest) or php7.4, see docker-bake.hcl
ARG ROADIZ_TAG=php7.2
# Inherits nginx, Node, Yarn and CVE-2026-109618 / CVE-2026-109619 mitigations
FROM roadiz/roadiz:${ROADIZ_TAG}
LABEL org.opencontainers.image.authors="Ambroise Maupate <ambroise@rezo-zero.com>"

RUN echo "date.timezone = Europe/Paris" > /usr/local/etc/php/conf.d/zzz-timezone.ini

ADD config /config
ADD etc /etc
