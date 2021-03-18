#!/bin/bash

echo "INFO: Init SSH for ${USER} user."

if ( id ${USER} ); then
    echo "INFO: User ${USER} already exists"
    echo "INFO: Change ${USER} password with environment:"
    echo "${USER}:${PASS}"|chpasswd
else
    echo "INFO: User ${USER} does not exist, we create it"
    ENC_PASS=$(perl -e 'print crypt($ARGV[0], "password")' ${PASS})
    groupadd --gid ${USER_UID} ${USER}
    useradd -d /data -m -p ${ENC_PASS} --uid ${USER_UID} --gid ${USER_UID} -s /bin/bash ${USER}
fi

if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
    echo "INFO: Host SSH keys do not exist, we create it"
    ssh-keygen -A
fi

echo "INFO: Launching SSH Daemon"

exec /usr/sbin/sshd -D
