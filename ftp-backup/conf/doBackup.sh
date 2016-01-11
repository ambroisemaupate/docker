#/bin/bash
MYSQLDUMP="$(which mysqldump)"
TAR="$(which tar)"
LFTP="$(which lftp)"
TAR_OPTIONS="-zcf"
FILE_DATE=`date +%Y%m%d-%H%M`
PRINT_DATE=`date '+%Y-%m-%d %H:%M:%S'`

echo "[${PRINT_DATE}] --> New backup"
echo "[${PRINT_DATE}] On ${FTP_PROTO}://${FTP_HOST}:${FTP_PORT}"

if [ -n "$FTP_HOST" ]
then
# Create remote dir if does not exists
echo "[${PRINT_DATE}] Create remote dir if does not exists…"
$LFTP -u ${FTP_USER},${FTP_PASS} ${FTP_PROTO}://${FTP_HOST}:${FTP_PORT} <<EOF

mkdir -p ${REMOTE_PATH}
bye

EOF

# Data backup
echo "[${PRINT_DATE}] Compressing /data folder…"
$TAR $TAR_OPTIONS /backups/data-$FILE_DATE.tar.gz /data

# Sending over FTP
echo "[${PRINT_DATE}] Sending /data folder over FTP…"
$LFTP -u ${FTP_USER},${FTP_PASS} ${FTP_PROTO}://${FTP_HOST}:${FTP_PORT} <<EOF

cd ${REMOTE_PATH}
ls
put /backups/data-${FILE_DATE}.tar.gz
bye

EOF

# MySQL dump
if [ -n "$DB_NAME" ]
then
# MySQL dump
echo "[${PRINT_DATE}] MySQL dump backup…"
$MYSQLDUMP -u $DB_USER -h $DB_HOST -p$DB_PASS $DB_NAME | gzip > /backups/db-$FILE_DATE.sql.gz

# Sending over FTP
echo "[${PRINT_DATE}] Sending MySQL dump over FTP…"
$LFTP -u ${FTP_USER},${FTP_PASS} ${FTP_PROTO}://${FTP_HOST}:${FTP_PORT} <<EOF

cd ${REMOTE_PATH}
ls
put /backups/db-${FILE_DATE}.sql.gz
bye

EOF
fi
fi

PRINT_ENDDATE=`date '+%H:%M:%S'`
echo "[${PRINT_DATE}] Backup finished at ${PRINT_ENDDATE}"

