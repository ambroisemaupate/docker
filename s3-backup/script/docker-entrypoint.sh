#!/usr/bin/env bash
# Author: Ambroise Maupate
set -e

# Create s3 config file
tee "${S3_CFG}" <<EOF >/dev/null
[default]
signature = ${S3_SIGNATURE}
# Object Storage Region FR-PAR
bucket_location = ${S3_BUCKET_LOCATION}
host_base = ${S3_HOST_BASE}
host_bucket = ${S3_HOST_BUCKET}
# Login credentials
access_key = ${S3_ACCESS_KEY}
secret_key = ${S3_SECRET_KEY}
EOF

exec "$@"

