#/bin/bash
MYSQLDUMP="$(which mysqldump)"
RSYNC="$(which rsync)"
TAR="$(which tar)"
TAR_OPTIONS="-zcf"

FILE_DATE=`date +%Y%m%d-%H%M`

# Data backup
$TAR $TAR_OPTIONS /backups/data-$FILE_DATE.tar.gz /data
# MySQL dump
$MYSQLDUMP -u $DB_USER -h $DB_HOST -p$DB_PASS $DB_NAME | bzip2 > /backups/db-$FILE_DATE.tar.gz

# Sending over FTP
lftp -u ${FTP_USER},${FTP_PASS} ftp://${FTP_HOST}:${FTP_PORT} <<EOF

cd ${REMOTE_PATH}

ls

put /backups/data-${FILE_DATE}.tar.gz
put /backups/db-${FILE_DATE}.tar.gz

bye

EOF
