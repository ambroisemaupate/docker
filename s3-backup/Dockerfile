FROM ubuntu:latest

# @see https://s3tools.org/usage
ENV S3_ACCESS_KEY=changeme
ENV S3_SECRET_KEY=changeme
ENV S3_SIGNATURE=s3v4
ENV S3_BUCKET_LOCATION=fr-par
ENV S3_HOST_BASE=https://s3.fr-par.scw.cloud
ENV S3_HOST_BUCKET=https://mybucket.s3.fr-par.scw.cloud
ENV S3_CFG="/root/.s3cfg"
ENV S3_CHUNK_SIZE=50
# Store object with specified CLASS (STANDARD,
# STANDARD_IA, or REDUCED_REDUNDANCY). Lower per-GB
# price. [put, cp, mv]
ENV S3_STORAGE_CLASS=STANDARD
ENV LOCAL_PATH=/var/www/html
ENV COMPRESS 1
# PostgreSQL defaults
ENV PGHOST=db
ENV PGPORT 5432
ENV PGUSER=postgres
ENV DEBIAN_FRONTEND=noninteractive
ENV GPG_PUBLIC_KEYS_PATH="/pubkeys.gpg"
ENV SENTRY_LOG_LEVEL=warn
ENV SENTRY_DISABLE_UPDATE_CHECK=1
ENV SENTRY_NO_PROGRESS_BAR=1

ADD script /script

RUN apt-get update -yqq && \
    apt-get install -yqq curl ca-certificates mysql-client postgresql-client s3cmd gzip gpg && \
    curl -sL https://sentry.io/get-cli/ | bash && \
    chmod +x /script/docker-entrypoint.sh /script/doBackup.sh

WORKDIR "/script"
ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["./doBackup.sh"]
