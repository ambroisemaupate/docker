#!/bin/sh
set -e

crond -s /etc/cron.d -f -L /dev/stdout "$@"