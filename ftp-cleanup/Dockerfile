FROM alpine:latest
MAINTAINER Ambroise Maupate <ambroise@rezo-zero.com>

ENV FTP_USER user
ENV FTP_PASS pass
ENV FTP_HOST mybackupserver.test
ENV FTP_PORT 21
ENV FTP_PROTO ftp
ENV STORE_DAYS 5
ENV FTP_PATH /my/backup/dir

ADD conf /conf

RUN apk --no-cache update \
    && apk --no-cache upgrade \
    && apk add --no-cache coreutils ca-certificates openssh lftp bash \
    && chmod +x /conf/doClean.sh \
    && echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config

ADD etc/lftp.conf /etc/lftp.conf

CMD ["/bin/bash","/conf/doClean.sh"]
