#!/usr/bin/env bash
# Author: Ambroise Maupate

MYSQLDUMP="/usr/bin/mysqldump"
PGDUMP="/usr/bin/pg_dump"
S3CMD="/usr/bin/s3cmd -c ${S3_CFG}"
TAR="/usr/bin/tar"
GPG="/usr/bin/gpg"
SENTRY_CLI="/usr/local/bin/sentry-cli"
SENTRY_OPTIONS="send-event -t bucket_name:${S3_BUCKET_NAME} -t folder_name:${S3_FOLDER_NAME} -t storage_class:${S3_STORAGE_CLASS} -m"
GPG_OPTIONS="--trust-model always --batch --yes --cipher-algo AES256 --digest-algo SHA256 --compress-level 0"
GZIP="/usr/bin/gzip"
TAR_OPTIONS="-zcf"
SQL_OPTIONS="--defaults-extra-file=/etc/mysql/temp_db.cnf --no-tablespaces --column-statistics=0"
S3_OPTIONS="--multipart-chunk-size-mb=${S3_CHUNK_SIZE} --storage-class=${S3_STORAGE_CLASS}"
FILE_DATE=`date +%Y%m%d_%H%M`
TMP_FOLDER=/tmp
# S3 remote path with ending slash
REMOTE_PATH="s3://${S3_BUCKET_NAME}/${S3_FOLDER_NAME}/"
TAR_FILE="${FILE_DATE}_files.tar.gz"
SQL_FILE="${FILE_DATE}_database.sql.gz"
ENCRYPT=0

function log {
    echo "[`date '+%Y-%m-%d %H:%M:%S'`] $1";
}

# Execute sentry-cli only if SENTRY_DSN is set
function sentry {
    if [[ -n "${SENTRY_DSN}" ]]; then
        $SENTRY_CLI $SENTRY_OPTIONS "[s3-backup] $1" --level=$2;
    fi
}

# If SENTRY_DSN env var is set, we will send a message to Sentry
if [[ -n "${SENTRY_DSN}" ]]; then
    eval "$(/usr/local/bin/sentry-cli bash-hook)"
fi

log "Beginning new backup on ${S3_HOST_BUCKET}"
sentry "Beginning new backup on ${S3_HOST_BUCKET}" "info";

# Checks if pubkeys.gpg file exists
if [[ -f "${GPG_PUBLIC_KEYS_PATH}" ]]; then
    log "Importing GPG public keys…";
    ${GPG} --import ${GPG_PUBLIC_KEYS_PATH};

    # Exit if import failed
    if [[ $? -ne 0 ]]; then
        log "GPG public keys import failed. Check your keys.";
        sentry "GPG public keys import failed" "error";
        exit 1;
    fi

    # Extract all fingerprints from imported keys in one string
    GPG_GROUP=`${GPG} --list-keys --with-colons | awk -F: '/^pub/{print $5}' | tr '\n' ' '`;
    ENCRYPT=1;
fi

# Test if connection is valid
${S3CMD} ls ${REMOTE_PATH};
if [[ $? -ne 0 ]]; then
    log "Cannot connect to bucket ${S3_BUCKET_NAME}. Check credentials."
    sentry "Cannot connect to bucket ${S3_BUCKET_NAME}" "error";
    exit 1;
fi

if [[ -d ${LOCAL_PATH} ]]; then

  if [[ $COMPRESS -eq 0 ]]; then
      log "Do not compress files backup"
      TAR_OPTIONS="-cf"
      TAR_FILE="${FILE_DATE}_files.tar"
  fi

  # Control will enter here if ${LOCAL_PATH} exists.
  log "Archiving ${LOCAL_PATH} folder…"
  $TAR $TAR_OPTIONS ${TMP_FOLDER}/${TAR_FILE} ${LOCAL_PATH}

  if [[ $ENCRYPT -eq 1 ]]; then
      log "Encrypting ${TMP_FOLDER}/${TAR_FILE} file…"
      ${GPG} $GPG_OPTIONS --encrypt --recipient defaults --group "defaults=${GPG_GROUP}" ${TMP_FOLDER}/${TAR_FILE}

      if [[ $? -ne 0 ]]; then
          log "GPG encryption failed. Check your keys.";
          sentry "GPG encryption failed" "error";
          exit 1;
      fi

      rm ${TMP_FOLDER}/${TAR_FILE}
      TAR_FILE="${TAR_FILE}.gpg"
  fi

  # Create md5sum file
  log "Creating md5sum file…"
  md5sum ${TMP_FOLDER}/${TAR_FILE} > ${TMP_FOLDER}/${TAR_FILE}.md5

  # Sending over S3
  log "Sending ${LOCAL_PATH} folder to S3 bucket…"
  ${S3CMD} put ${S3_OPTIONS} ${TMP_FOLDER}/${TAR_FILE} ${REMOTE_PATH};
  ${S3CMD} put ${S3_OPTIONS} ${TMP_FOLDER}/${TAR_FILE}.md5 ${REMOTE_PATH};
else
  log "${LOCAL_PATH} folder does not exists. No files to backup"
  sentry "${LOCAL_PATH} folder does not exists. No files to backup" "warn";
  # Do not prevent databases to backup
fi

#
# Optional MySQL dump
#
if [[ ! -n "${DB_NAME}" ]]; then
  log "No MySQL database to backup."
else
  # MySQL dump
  log "MySQL dump backup…"
  # Create credential client file to avoid WARNING messages
  cat > /etc/mysql/temp_db.cnf <<- EOF
[client]
user = "${DB_USER}"
password = "${DB_PASS}"
host = "${DB_HOST}"
EOF

  $MYSQLDUMP $SQL_OPTIONS -u $DB_USER -h $DB_HOST $DB_NAME | gzip > ${TMP_FOLDER}/${SQL_FILE}

  if [[ $? -ne 0 ]]; then
      log "MySQL Dump failed, check connection or credentials.";
      sentry "MySQL Dump failed, check connection or credentials." "error";
      exit 1;
  fi

  if [[ $ENCRYPT -eq 1 ]]; then
    log "Encrypting ${TMP_FOLDER}/${SQL_FILE} file…"
    ${GPG} $GPG_OPTIONS --encrypt --recipient defaults --group "defaults=${GPG_GROUP}" ${TMP_FOLDER}/${SQL_FILE}

    if [[ $? -ne 0 ]]; then
        log "GPG encryption failed. Check your keys.";
        sentry "GPG encryption failed." "error";
        exit 1;
    fi

    rm ${TMP_FOLDER}/${SQL_FILE}
    SQL_FILE="${SQL_FILE}.gpg"
  fi

  # Create md5sum file
  log "Creating md5sum file…"
  md5sum ${TMP_FOLDER}/${SQL_FILE} > ${TMP_FOLDER}/${SQL_FILE}.md5
  # Sending over FTP
  log "Sending MySQL dump to S3 bucket…"
  ${S3CMD} put ${S3_OPTIONS} ${TMP_FOLDER}/${SQL_FILE} ${REMOTE_PATH};
  ${S3CMD} put ${S3_OPTIONS} ${TMP_FOLDER}/${SQL_FILE}.md5 ${REMOTE_PATH};
fi

#
# Optional Postgres dump
#
if [[ ! -n "${PGDATABASE}" ]]; then
  log "No PostgreSQL database to backup."
else
  # PostgreSQL dump
  log "PostgreSQL dump backup…"

  cat > ~/.pgpass <<- EOF
${PGHOST}:${PGPORT}:${PGDATABASE}:${PGUSER}:${PGPASSWORD}
EOF

  $PGDUMP --no-password $PGDATABASE | gzip > ${TMP_FOLDER}/${SQL_FILE}

  if [[ $? -ne 0 ]]; then
      log "PostgreSQL Dump failed, check connection or credentials.";
      sentry "PostgreSQL Dump failed, check connection or credentials." "error";
      exit 1;
  fi

  if [[ $ENCRYPT -eq 1 ]]; then
    log "Encrypting ${TMP_FOLDER}/${SQL_FILE} file…"
    ${GPG} $GPG_OPTIONS --encrypt --recipient defaults --group "defaults=${GPG_GROUP}" ${TMP_FOLDER}/${SQL_FILE}

    if [[ $? -ne 0 ]]; then
        log "GPG encryption failed. Check your keys.";
        sentry "GPG encryption failed." "error";
        exit 1;
    fi

    rm ${TMP_FOLDER}/${SQL_FILE}
    SQL_FILE="${SQL_FILE}.gpg"
  fi

  # Create md5sum file
  log "Creating md5sum file…"
  md5sum ${TMP_FOLDER}/${SQL_FILE} > ${TMP_FOLDER}/${SQL_FILE}.md5
  # Sending over FTP
  log "Sending PostgreSQL dump to S3 bucket…"
  ${S3CMD} put ${S3_OPTIONS} ${TMP_FOLDER}/${SQL_FILE} ${REMOTE_PATH};
  ${S3CMD} put ${S3_OPTIONS} ${TMP_FOLDER}/${SQL_FILE}.md5 ${REMOTE_PATH};
fi

${S3CMD} ls ${REMOTE_PATH};
log "Backup finished"
sentry "Backup finished." "info";
