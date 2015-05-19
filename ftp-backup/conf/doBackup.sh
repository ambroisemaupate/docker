#/bin/bash
MYSQLDUMP="$(which mysqldump)"
TAR="$(which tar)"
LFTP="$(which lftp)"
TAR_OPTIONS="-zcf"
FILE_DATE=`date +%Y%m%d-%H%M`

echo "[${FILE_DATE}] New backup --------"

if [ -n "$FTP_HOST" ]
then
# Create remote dir if does not exists
$LFTP -u ${FTP_USER},${FTP_PASS} ftp://${FTP_HOST}:${FTP_PORT} <<EOF

mkdir -p ${REMOTE_PATH}
bye

EOF

# Data backup
$TAR $TAR_OPTIONS /backups/data-$FILE_DATE.tar.gz /data

# Sending over FTP
$LFTP -u ${FTP_USER},${FTP_PASS} ftp://${FTP_HOST}:${FTP_PORT} <<EOF

cd ${REMOTE_PATH}
ls
put /backups/data-${FILE_DATE}.tar.gz
bye

EOF

# MySQL dump
if [ -n "$DB_NAME" ]
then
echo "MySQL dump backup ---"
# MySQL dump
$MYSQLDUMP -u $DB_USER -h $DB_HOST -p$DB_PASS $DB_NAME | gzip > /backups/db-$FILE_DATE.sql.gz

# Sending over FTP
$LFTP -u ${FTP_USER},${FTP_PASS} ftp://${FTP_HOST}:${FTP_PORT} <<EOF

cd ${REMOTE_PATH}
ls
put /backups/db-${FILE_DATE}.sql.gz
bye

EOF
fi
fi
