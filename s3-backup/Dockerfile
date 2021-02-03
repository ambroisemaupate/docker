FROM ubuntu:latest

ENV S3_ACCESS_KEY=changeme
ENV S3_SECRET_KEY=changeme
ENV S3_SIGNATURE=s3v4
ENV S3_BUCKET_LOCATION=fr-par
ENV S3_HOST_BASE=https://s3.fr-par.scw.cloud
ENV S3_HOST_BUCKET=https://mybucket.s3.fr-par.scw.cloud
ENV S3_CFG="/root/.s3cfg"
ENV LOCAL_PATH=/var/www/html

ADD script /script

RUN apt-get update -yqq && \
    apt-get install -yqq ca-certificates mysql-client s3cmd gzip && \
    chmod +x /script/docker-entrypoint.sh /script/doBackup.sh

WORKDIR "/script"
ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["./doBackup.sh"]
