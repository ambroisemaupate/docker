FROM debian:jessie
MAINTAINER Ambroise Maupate <ambroise@rezo-zero.com>
ADD etc /etc
CMD /config/loop
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
	apt-get upgrade -y && \
	apt-get install -y ca-certificates cron inotify-tools nano pwgen supervisor unrar unzip wget logrotate && \
	apt-get clean && \
	echo -n > /var/lib/apt/extended_states
RUN mkdir /config /data
RUN useradd -u 500 core
ADD config /config
ADD supervisord.conf /etc/supervisor/conf.d/cron.conf
RUN chmod +x /config/loop
