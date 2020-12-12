#!/usr/bin/env bash
# Author: Ambroise Maupate

MYSQLDUMP="$(which mysqldump)"
S3CMD="$(which s3cmd) -c ${S3_CFG}"
TAR="$(which tar)"
GZIP="$(which gzip)"
TAR_OPTIONS="-zcf"
FILE_DATE=`date +%Y%m%d_%H%M`
TMP_FOLDER=/tmp
# S3 remote path with ending slash
REMOTE_PATH="s3://${S3_BUCKET_NAME}/${S3_FOLDER_NAME}/"

echo "[`date '+%Y-%m-%d %H:%M:%S'`] ============================================================="
echo "[`date '+%Y-%m-%d %H:%M:%S'`] Beginning new backup on ${S3_HOST_BUCKET}"

# Test if connection is valid
${S3CMD} ls ${REMOTE_PATH};
if [[ $? -ne 0 ]]; then
    echo "Cannot connect to bucket ${S3_BUCKET_NAME}. Check credentials."
    exit 1;
fi

if [[ -d ${LOCAL_PATH} ]]; then
  # Control will enter here if ${LOCAL_PATH} exists.
  echo "[`date '+%Y-%m-%d %H:%M:%S'`] Compressing ${LOCAL_PATH} folder…"
  $TAR $TAR_OPTIONS ${TMP_FOLDER}/${FILE_DATE}_files.tar.gz ${LOCAL_PATH}
  # Sending over S3
  echo "[`date '+%Y-%m-%d %H:%M:%S'`] Sending ${LOCAL_PATH} folder over FTP…"
  ${S3CMD} put ${TMP_FOLDER}/${FILE_DATE}_files.tar.gz ${REMOTE_PATH};
else
  echo "[`date '+%Y-%m-%d %H:%M:%S'`] ${LOCAL_PATH} folder does not exists."
  exit 1
fi

# Optional MySQL dump
if [[ ! -n "${DB_NAME}" ]]; then
  echo "[`date '+%Y-%m-%d %H:%M:%S'`] No database to backup."
else
  # MySQL dump
  echo "[`date '+%Y-%m-%d %H:%M:%S'`] MySQL dump backup…"
  $MYSQLDUMP --column-statistics=0 -u $DB_USER -h $DB_HOST --password=$DB_PASS $DB_NAME | gzip > ${TMP_FOLDER}/${FILE_DATE}_database.sql.gz
  # Sending over FTP
  echo "[`date '+%Y-%m-%d %H:%M:%S'`] Sending MySQL dump over FTP…"
  ${S3CMD} put ${TMP_FOLDER}/${FILE_DATE}_database.sql.gz ${REMOTE_PATH};
fi

${S3CMD} ls ${REMOTE_PATH};
echo "[`date '+%Y-%m-%d %H:%M:%S'`] Backup finished"

