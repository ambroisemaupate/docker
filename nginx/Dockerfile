FROM ambroisemaupate/debian:latest
MAINTAINER Ambroise Maupate <ambroise@rezo-zero.com>

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ABF5BD827BD9BF62 && \
    echo "deb http://nginx.org/packages/mainline/debian/ buster nginx" > /etc/apt/sources.list.d/nginx.list && \
    apt-get update && \
    apt-get install -y -q --no-install-recommends nginx && \
    apt-get clean && \
    echo -n > /var/lib/apt/extended_states && \
    rm -rf /etc/nginx/*.d && \
    mkdir -p /etc/nginx/addon.d /etc/nginx/conf.d /etc/nginx/host.d /etc/nginx/nginx.d && \
    rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin

ADD config /config
ADD etc /etc
ADD supervisord.conf /etc/supervisor/conf.d/nginx.conf
EXPOSE 80
