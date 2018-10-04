#! /bin/sh
# Mainly inspired by DynHost script given by OVH
# New version by zwindler (zwindler.fr/wordpress)
#
# Initial version was doing  nasty grep/cut on local ppp0 interface
#
# This coulnd't work in a NATed environnement like on ISP boxes
# on private networks.
#
# Also got rid of ipcheck.py thanks to mafiaman42
#
# This script uses curl to get the public IP, and then uses wget
# to update DynHost entry in OVH DNS
#
# Logfile: dynhost.log
#
# CHANGE: "HOST", "LOGIN" and "PASSWORD" to reflect YOUR account variables
SCRIPT_PATH='/srv/dyndns'

getip() {
    IP=`curl http://ifconfig.me/ip`
    OLDIP=`dig +short $HOST @$NSSERVER`
}

echo "[`date '+%Y-%m-%d %H:%M:%S'`] ============================================================="
echo "[`date '+%Y-%m-%d %H:%M:%S'`] Begining new dyndns check"
getip

if [ "$IP" ]; then
    echo "[`date '+%Y-%m-%d %H:%M:%S'`] Old IP is ${OLDIP}"
    echo "[`date '+%Y-%m-%d %H:%M:%S'`] New IP is ${IP}"

    if [ "$OLDIP" != "$IP" ]; then
        echo "[`date '+%Y-%m-%d %H:%M:%S'`] Update is needed…"
        wget "${ENTRYPOINT}?system=dyndns&hostname=${HOST}&myip=${IP}" --user="${LOGIN}" --password="${PASSWORD}"
        echo -n "$IP" > $SCRIPT_PATH/old.ip
    else
        echo "[`date '+%Y-%m-%d %H:%M:%S'`] No update required."
    fi
 else
    echo "[`date '+%Y-%m-%d %H:%M:%S'`] WAN IP not found. Exiting!"
 fi