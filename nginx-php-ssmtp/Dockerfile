FROM ambroisemaupate/nginx-php
MAINTAINER Ambroise Maupate <ambroise@rezo-zero.com>

# Install sSMTP for mail support
RUN apt-get update && \
    apt-get install -y -q --no-install-recommends ssmtp && \
    rm -r /var/lib/apt/lists/* && \
    apt-get clean && \
    echo -n > /var/lib/apt/extended_states && \
    rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin

ADD etc /etc
RUN phpenmod ssmtp
