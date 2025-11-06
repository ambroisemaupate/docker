#!/bin/sh
# Author: Ambroise Maupate

function log {
    echo "[`date '+%Y-%m-%d %H:%M:%S'`] $1";
}

#
# Optional MySQL dump
#
if [[ ! -n "${MYSQL_DATABASE}" ]]; then
  log "No MySQL database to backup."
else
  # MySQL dump
  log "MySQL dump backup using ${MYSQLDUMP}…"
  # Create credential client file to avoid WARNING messages
  cat > /temp_db.cnf <<- EOF
[client]
user = "${MYSQL_USER}"
password = "${MYSQL_PASSWORD}"
host = "${MYSQL_DATABASE}"
EOF

  $MYSQLDUMP $SQL_OPTIONS -u $MYSQL_USER -h $MYSQL_HOST $MYSQL_DATABASE > $MYSQL_DUMP_FILENAME
  if [[ $? -ne 0 ]]; then
    log "MySQL Dump failed, check connection or credentials.";
    exit 1;
  fi
fi

#
# Optional Postgres dump
#
if [[ ! -n "${PG_DATABASE}" ]]; then
  log "No PostgreSQL database to backup."
else
  # PostgreSQL dump
  log "PostgreSQL dump backup…"

  cat > ~/.pgpass <<- EOF
${PG_HOST}:${PG_PORT}:${PG_DATABASE}:${PG_USER}:${PG_PASSWORD}
EOF
  chmod 0600 ~/.pgpass
  $PGDUMP -h $PG_HOST -p $PG_PORT -U $PG_USER --no-password $PG_DATABASE > $PG_DUMP_FILENAME
  if [[ $? -ne 0 ]]; then
    log "PostgreSQL Dump failed, check connection or credentials.";
    exit 1;
  fi
fi

exec /usr/bin/restic "$@"
