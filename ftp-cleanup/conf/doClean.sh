#!/bin/bash
# Simple script to delete files older than specific number of days from FTP. Provided AS IS without any warranty.
# This script use 'lftp'. And 'date' with '-d' option which is not POSIX compatible.

# Full path to lftp executable
LFTP=`which lftp`
LFTP_CMD="-u ${FTP_USER},${FTP_PASS} ${FTP_PROTO}://${FTP_HOST}:${FTP_PORT}"

function removeOlderThanDays() {

# Make some temp files to store intermediate data
LIST=`mktemp`
DELLIST=`mktemp`

# Connect to ftp get file list and store it into temp file
${LFTP} ${LFTP_CMD} << EOF
cd ${FTP_PATH}
cache flush
cls -q -1 --date --time-style="+%Y%m%d" > ${LIST}
quit
EOF

if [ $? -ne 0 ]; then
    echo "Cannot connect to FTP account. Check credentials."
    exit 1;
fi

# Print obtained list, uncomment for debug
echo "=== File list ==="
cat ${LIST}
if [ $(cat ${LIST} | wc -l) -le 2 ]; then
    echo "Only one backup is available. Do nothing."
    exit 0;
fi
# Delete list header, uncomment for debug
echo "=== Delete list ==="

# Let's find date to compare
STORE_DATE=$(date -d "now - ${STORE_DAYS} days" '+%Y%m%d')
while read LINE; do
    if [[ ${STORE_DATE} -ge ${LINE:0:8} && "${LINE}" != *\/ ]]; then
        echo "rm -f \"${LINE:9}\"" >> ${DELLIST}
        # Print files wich is subject to delete, uncomment for debug
        echo "${LINE:9}"
    fi
done < ${LIST}
# More debug strings
echo "Delete list complete"
# Print notify if list is empty and exit.
if [ ! -f ${DELLIST}  ] || [ -z "$(cat ${DELLIST})" ]; then
    echo "Delete list doesn't exist or empty, nothing to delete. Exiting"
    exit 0;
fi

# Connect to ftp and delete files by previously formed list
${LFTP} ${LFTP_CMD} << EOF
cd ${FTP_PATH}
$(cat ${DELLIST})
ls
quit
EOF

# Remove temp files
rm ${LIST} ${DELLIST}

}

removeOlderThanDays