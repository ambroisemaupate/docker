#!/usr/bin/env bash
# Author: Ambroise Maupate

PGDUMP="$(which pg_dump)"
MYSQLDUMP="$(which mysqldump)"
TAR="$(which tar)"
LFTP="$(which lftp)"
GZIP="$(which gzip)"
TAR_OPTIONS="-zcf"
SQL_OPTIONS="--defaults-extra-file=/etc/mysql/temp_db.cnf --no-tablespaces --column-statistics=0"
FILE_DATE=`date +%Y%m%d_%H%M`
TMP_FOLDER=/tmp
TAR_FILE="${FILE_DATE}_files.tar.gz"
SQL_FILE="${FILE_DATE}_database.sql.gz"

echo "[`date '+%Y-%m-%d %H:%M:%S'`] =============================================================="
echo "[`date '+%Y-%m-%d %H:%M:%S'`] Beginning new backup on ${FTP_PROTO}://${FTP_HOST}:${FTP_PORT}"

if [[ $COMPRESS -eq 0 ]]; then
    echo "[`date '+%Y-%m-%d %H:%M:%S'`] Do not compress files backup"
    TAR_OPTIONS="-cf"
    TAR_FILE="${FILE_DATE}_files.tar"
fi

LFTP_CMD="-u ${FTP_USER},${FTP_PASS} ${FTP_PROTO}://${FTP_HOST}:${FTP_PORT}"

# Test if connection is valid
${LFTP} -e "pwd;bye;" ${LFTP_CMD};
if [[ $? -ne 0 ]]; then
    echo "[`date '+%Y-%m-%d %H:%M:%S'`] Cannot connect to remote ${FTP_PROTO} account. Check credentials."
    exit 1;
fi

if [[ -n "$FTP_HOST" ]]; then
    # Create remote dir if does not exists
    echo "[`date '+%Y-%m-%d %H:%M:%S'`] Create remote dir if does not exists…"
    ${LFTP} ${LFTP_CMD} <<EOF
cache flush;
cd ${REMOTE_PATH} || mkdir -p ${REMOTE_PATH};
bye;
EOF
fi

${LFTP} -e "cache flush;cd ${REMOTE_PATH};bye;" ${LFTP_CMD};
if [[ $? -ne 0 ]]; then
    echo "Remote path ${REMOTE_PATH} does not exist."
    exit 1;
fi

if [[ -d ${LOCAL_PATH} ]]; then
  # Control will enter here if /data exists.
  echo "[`date '+%Y-%m-%d %H:%M:%S'`] Archiving ${LOCAL_PATH} folder…"
  $TAR $TAR_OPTIONS ${TMP_FOLDER}/${TAR_FILE} ${LOCAL_PATH}

  # Sending over FTP
  echo "[`date '+%Y-%m-%d %H:%M:%S'`] Sending ${LOCAL_PATH} folder over FTP…"
  ${LFTP} ${LFTP_CMD} <<EOF
cache flush;
cd ${REMOTE_PATH};
put ${TMP_FOLDER}/${TAR_FILE};
bye;
EOF
else
  echo "[`date '+%Y-%m-%d %H:%M:%S'`] ${LOCAL_PATH} folder does not exists."
  exit 1
fi

#
# Optional MySQL dump
#
if [[ ! -n "${DB_NAME}" ]]; then
  echo "[`date '+%Y-%m-%d %H:%M:%S'`] No database to backup."
else
  # MySQL dump
  echo "[`date '+%Y-%m-%d %H:%M:%S'`] MySQL dump backup…"
  # Create credential client file to avoid WARNING messages
  cat > /etc/mysql/temp_db.cnf <<- EOF
[client]
user = "${DB_USER}"
password = "${DB_PASS}"
host = "${DB_HOST}"
EOF

  $MYSQLDUMP $SQL_OPTIONS -u $DB_USER -h $DB_HOST $DB_NAME | gzip > ${TMP_FOLDER}/${SQL_FILE}

  # Sending over FTP
  echo "[`date '+%Y-%m-%d %H:%M:%S'`] Sending MySQL dump over FTP…"
  ${LFTP} ${LFTP_CMD} <<EOF
cache flush;
cd ${REMOTE_PATH};
put ${TMP_FOLDER}/${SQL_FILE};
ls;
bye;
EOF
fi

#
# Optional Postgres dump
#
if [[ ! -n "${PGDATABASE}" ]]; then
  echo "[`date '+%Y-%m-%d %H:%M:%S'`] No PostgreSQL database to backup."
else
  # PostgreSQL dump
  echo "[`date '+%Y-%m-%d %H:%M:%S'`] PostgreSQL dump backup…"

  cat > ~/.pgpass <<- EOF
${PGHOST}:${PGPORT}:${PGDATABASE}:${PGUSER}:${PGPASSWORD}
EOF

  $PGDUMP --no-password $PGDATABASE | gzip > ${TMP_FOLDER}/${SQL_FILE}
  # Sending over FTP
  echo "[`date '+%Y-%m-%d %H:%M:%S'`] Sending PostgreSQL dump over FTP…"
  ${LFTP} ${LFTP_CMD} <<EOF
cache flush;
cd ${REMOTE_PATH};
put ${TMP_FOLDER}/${SQL_FILE};
ls;
bye;
EOF
fi

echo "[`date '+%Y-%m-%d %H:%M:%S'`] Backup finished"

