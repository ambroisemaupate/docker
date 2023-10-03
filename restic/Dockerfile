FROM restic/restic:latest
MAINTAINER "Ambroise Maupate <ambroise@rezo-zero.com>"

ENV MYSQL_HOST=db
ENV MYSQL_DUMP_FILENAME=database_dump.sql

ENV PG_HOST=db
ENV PG_PORT 5432
ENV PG_USER=postgres
ENV PG_DUMP_FILENAME=database_dump.sql

COPY entrypoint.sh /entrypoint.sh
RUN apk add --update --no-cache mysql-client postgresql-client mariadb-connector-c-dev && \
    chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
