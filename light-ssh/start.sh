#!/bin/bash

if ( id ${USER} ); then
    echo "INFO: User ${USER} already exists"
else
    echo "INFO: User ${USER} does not exists, we create it"
    ENC_PASS=$(perl -e 'print crypt($ARGV[0], "password")' ${PASS})
    useradd -d /data -m -p ${ENC_PASS} -u ${USER_UID} -s /bin/bash ${USER}
fi

exec /usr/sbin/sshd -D