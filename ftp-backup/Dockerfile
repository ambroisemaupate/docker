FROM ubuntu:latest
MAINTAINER Ambroise Maupate <ambroise@rezo-zero.com>
LABEL description="Backup a data-oriented container and a \
MariaDB/MySQL container and upload them to a FTP server using lftp." \
vendor="Ambroise Maupate"

ADD conf /conf

ENV DEBIAN_FRONTEND noninteractive
ENV FTP_USER user
ENV FTP_PASS pass
ENV FTP_HOST mybackupserver.test
ENV FTP_PORT 21
ENV FTP_PROTO ftp
ENV LOCAL_PATH /data
ENV REMOTE_PATH /my/backup/dir

RUN apt-get update -yqq && \
    apt-get install -y ca-certificates openssh-client mysql-client lftp && \
    mkdir -p /backups

ADD etc/lftp.conf /etc/lftp.conf

CMD ["/bin/bash","/conf/doBackup.sh"]
