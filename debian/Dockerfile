FROM debian:buster
MAINTAINER Ambroise Maupate <ambroise@rezo-zero.com>

ADD etc /etc
CMD /config/loop
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y -q --no-install-recommends locales curl git ca-certificates cron openssh-client inotify-tools nano pwgen supervisor unrar unzip wget logrotate gnupg && \
    apt-get clean && \
    echo -n > /var/lib/apt/extended_states && \
    rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin && \
    mkdir /config /data && \
    useradd -u 500 -d /data -s /bin/bash core

ADD config /config
ADD supervisord.conf /etc/supervisor/conf.d/cron.conf
RUN chmod +x /config/loop

VOLUME /data
