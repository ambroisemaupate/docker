#!/usr/bin/env bash
# Author: Ambroise Maupate

MYSQLDUMP="$(which mysqldump)"
TAR="$(which tar)"
LFTP="$(which lftp)"
GZIP="$(which gzip)"
TAR_OPTIONS="-zcf"
FILE_DATE=`date +%Y%m%d-%H%M`

echo "[`date '+%Y-%m-%d %H:%M:%S'`] Begining new backup on ${FTP_PROTO}://${FTP_HOST}:${FTP_PORT}"

LFTP_CMD="-u ${FTP_USER},${FTP_PASS} ${FTP_PROTO}://${FTP_HOST}:${FTP_PORT}"

if [ -n "$FTP_HOST" ]
then
# Create remote dir if does not exists
echo "[`date '+%Y-%m-%d %H:%M:%S'`] Create remote dir if does not exists…"
${LFTP} ${LFTP_CMD} <<EOF
cd ${REMOTE_PATH} || mkdir -p ${REMOTE_PATH};
bye;
EOF

if [ -d ${LOCAL_PATH} ]; then
  # Control will enter here if /data exists.
  echo "[`date '+%Y-%m-%d %H:%M:%S'`] Compressing ${LOCAL_PATH} folder…"
  $TAR $TAR_OPTIONS /backups/data-$FILE_DATE.tar.gz ${LOCAL_PATH}

  # Sending over FTP
  echo "[`date '+%Y-%m-%d %H:%M:%S'`] Sending ${LOCAL_PATH} folder over FTP…"
  ${LFTP} ${LFTP_CMD} <<EOF
cd ${REMOTE_PATH};
ls;
put /backups/data-${FILE_DATE}.tar.gz;
bye;
EOF
else
  echo "[`date '+%Y-%m-%d %H:%M:%S'`] ${LOCAL_PATH} folder does not exists."
  exit 1
fi


# Optional MySQL dump
if [ -n "$DB_NAME" ]
  echo "[`date '+%Y-%m-%d %H:%M:%S'`] No database to backup."
then
# MySQL dump
echo "[`date '+%Y-%m-%d %H:%M:%S'`] MySQL dump backup…"
$MYSQLDUMP -u $DB_USER -h $DB_HOST --password=$DB_PASS $DB_NAME | gzip > /backups/db-$FILE_DATE.sql.gz

# Sending over FTP
echo "[`date '+%Y-%m-%d %H:%M:%S'`] Sending MySQL dump over FTP…"
${LFTP} ${LFTP_CMD} <<EOF
cd ${REMOTE_PATH};
ls;
put /backups/db-${FILE_DATE}.sql.gz;
bye;
EOF
fi
fi

echo "[`date '+%Y-%m-%d %H:%M:%S'`] Backup finished"

