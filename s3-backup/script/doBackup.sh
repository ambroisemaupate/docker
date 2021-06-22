#!/usr/bin/env bash
# Author: Ambroise Maupate

MYSQLDUMP="$(which mysqldump)"
PGDUMP="$(which pg_dump)"
S3CMD="$(which s3cmd) -c ${S3_CFG}"
TAR="$(which tar)"
GZIP="$(which gzip)"
TAR_OPTIONS="-zcf"
SQL_OPTIONS="--defaults-extra-file=/etc/mysql/temp_db.cnf --no-tablespaces --column-statistics=0"
S3_OPTIONS="--multipart-chunk-size-mb=${S3_CHUNK_SIZE}"
FILE_DATE=`date +%Y%m%d_%H%M`
TMP_FOLDER=/tmp
# S3 remote path with ending slash
REMOTE_PATH="s3://${S3_BUCKET_NAME}/${S3_FOLDER_NAME}/"
TAR_FILE="${FILE_DATE}_files.tar.gz"
SQL_FILE="${FILE_DATE}_database.sql.gz"

echo "[`date '+%Y-%m-%d %H:%M:%S'`] ============================================================="
echo "[`date '+%Y-%m-%d %H:%M:%S'`] Beginning new backup on ${S3_HOST_BUCKET}"

if [[ $COMPRESS -eq 0 ]]; then
    echo "[`date '+%Y-%m-%d %H:%M:%S'`] Do not compress files backup"
    TAR_OPTIONS="-cf"
    TAR_FILE="${FILE_DATE}_files.tar"
fi

# Test if connection is valid
${S3CMD} ls ${REMOTE_PATH};
if [[ $? -ne 0 ]]; then
    echo "[`date '+%Y-%m-%d %H:%M:%S'`] Cannot connect to bucket ${S3_BUCKET_NAME}. Check credentials."
    exit 1;
fi

if [[ -d ${LOCAL_PATH} ]]; then
  # Control will enter here if ${LOCAL_PATH} exists.
  echo "[`date '+%Y-%m-%d %H:%M:%S'`] Compressing ${LOCAL_PATH} folder…"
  $TAR $TAR_OPTIONS ${TMP_FOLDER}/${TAR_FILE} ${LOCAL_PATH}
  # Sending over S3
  echo "[`date '+%Y-%m-%d %H:%M:%S'`] Sending ${LOCAL_PATH} folder to S3 bucket…"
  ${S3CMD} put ${TMP_FOLDER}/${TAR_FILE} ${REMOTE_PATH};
else
  echo "[`date '+%Y-%m-%d %H:%M:%S'`] ${LOCAL_PATH} folder does not exists. No files to backup"
  # Do not prevent databases to backup
fi

#
# Optional MySQL dump
#
if [[ ! -n "${DB_NAME}" ]]; then
  echo "[`date '+%Y-%m-%d %H:%M:%S'`] No MySQL database to backup."
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
  echo "[`date '+%Y-%m-%d %H:%M:%S'`] Sending MySQL dump to S3 bucket…"
  ${S3CMD} put ${S3_OPTIONS} ${TMP_FOLDER}/${SQL_FILE} ${REMOTE_PATH};
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
  echo "[`date '+%Y-%m-%d %H:%M:%S'`] Sending PostgreSQL dump to S3 bucket…"
  ${S3CMD} put ${S3_OPTIONS} ${TMP_FOLDER}/${SQL_FILE} ${REMOTE_PATH};
fi

${S3CMD} ls ${REMOTE_PATH};
echo "[`date '+%Y-%m-%d %H:%M:%S'`] Backup finished"

