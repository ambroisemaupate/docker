#!/bin/sh
set -e

crond -s /etc/cron.d -f -L /proc/self/fd/1 "$@"