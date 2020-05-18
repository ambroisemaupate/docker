#!/usr/bin/env bash
# Author: Ambroise Maupate

MYSQLDUMP="$(which mysqldump)"
TAR="$(which tar)"
LFTP="$(which lftp)"
GZIP="$(which gzip)"
TAR_OPTIONS="-zcf"
FILE_DATE=`date +%Y%m%d_%H%M`
TMP_FOLDER=/tmp

echo "[`date '+%Y-%m-%d %H:%M:%S'`] ============================================================="
echo "[`date '+%Y-%m-%d %H:%M:%S'`] Begining new backup on ${FTP_PROTO}://${FTP_HOST}:${FTP_PORT}"

LFTP_CMD="-u ${FTP_USER},${FTP_PASS} ${FTP_PROTO}://${FTP_HOST}:${FTP_PORT}"

# Test if connection is valid
${LFTP} -e "pwd;bye;" ${LFTP_CMD};
if [[ $? -ne 0 ]]; then
    echo "Cannot connect to remote ${FTP_PROTO} account. Check credentials."
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
  echo "[`date '+%Y-%m-%d %H:%M:%S'`] Compressing ${LOCAL_PATH} folder…"
  $TAR $TAR_OPTIONS ${TMP_FOLDER}/${FILE_DATE}_files.tar.gz ${LOCAL_PATH}

  # Sending over FTP
  echo "[`date '+%Y-%m-%d %H:%M:%S'`] Sending ${LOCAL_PATH} folder over FTP…"
  ${LFTP} ${LFTP_CMD} <<EOF
cache flush;
cd ${REMOTE_PATH};
put ${TMP_FOLDER}/${FILE_DATE}_files.tar.gz;
bye;
EOF
else
  echo "[`date '+%Y-%m-%d %H:%M:%S'`] ${LOCAL_PATH} folder does not exists."
  exit 1
fi


# Optional MySQL dump
if [[ ! -n "${DB_NAME}" ]]; then
  echo "[`date '+%Y-%m-%d %H:%M:%S'`] No database ${DB_NAME} to backup."
else
  # MySQL dump
  echo "[`date '+%Y-%m-%d %H:%M:%S'`] MySQL dump backup…"
  $MYSQLDUMP --column-statistics=0 -u $DB_USER -h $DB_HOST --password=$DB_PASS $DB_NAME | gzip > ${TMP_FOLDER}/${FILE_DATE}_database.sql.gz

  # Sending over FTP
  echo "[`date '+%Y-%m-%d %H:%M:%S'`] Sending MySQL dump over FTP…"
  ${LFTP} ${LFTP_CMD} <<EOF
cache flush;
cd ${REMOTE_PATH};
put ${TMP_FOLDER}/${FILE_DATE}_database.sql.gz;
ls;
bye;
EOF
fi

echo "[`date '+%Y-%m-%d %H:%M:%S'`] Backup finished"

