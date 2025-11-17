FROM restic/restic:latest AS base
LABEL org.opencontainers.image.authors="Ambroise Maupate <ambroise@rezo-zero.com>"

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]


FROM base AS mysql

ENV MYSQL_HOST=db
ENV MYSQL_DUMP_FILENAME=database_dump.sql
#ENV MYSQLDUMP="/usr/bin/mysqldump"
ENV MYSQLDUMP="/usr/bin/mariadb-dump"
ENV SQL_OPTIONS="--defaults-extra-file=/temp_db.cnf --no-tablespaces --skip-ssl"

RUN apk add --update --no-cache mysql-client mariadb-connector-c-dev


FROM base AS postgres

ENV PG_HOST=db
ENV PG_PORT=5432
ENV PG_USER=postgres
ENV PG_DUMP_FILENAME=database_dump.sql
ENV PGDUMP="/usr/bin/pg_dump"

RUN apk add --update --no-cache postgresql-client


FROM base AS mariadb

ENV MYSQL_HOST=db
ENV MYSQL_DUMP_FILENAME=database_dump.sql
ENV MYSQLDUMP="/usr/bin/mariadb-dump"
ENV SQL_OPTIONS="--defaults-extra-file=/temp_db.cnf --no-tablespaces --skip-ssl"

RUN apk add --update --no-cache mariadb-client mariadb-connector-c-dev
