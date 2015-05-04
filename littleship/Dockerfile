FROM maxexcloo/nginx-php:latest
MAINTAINER Ambroise Maupate <ambroise@rezo-zero.com>

ENV DEBIAN_FRONTEND noninteractive

RUN addgroup --gid 999 docker && \
    usermod -aG docker core

ADD config /config

