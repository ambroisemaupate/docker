# s3cmd backup image
**Backup any local folder/volume to a S3 compatible object storage location**

Tested with:

- *Scaleway* Object storage
    
**s3cmd will manage all files in your bucket**. Do not upload other files manually, or they
will be remove once their expiration datetime is passed. Use a dedicated bucket.

## ENV variables

See https://www.scaleway.com/en/docs/object-storage-with-s3cmd/ to populate your `.env` vars:

* `S3_ACCESS_KEY`
* `S3_SECRET_KEY`
* `S3_SIGNATURE`
* `S3_BUCKET_LOCATION`
* `S3_HOST_BASE`
* `S3_HOST_BUCKET`
* `S3_BUCKET_NAME` - Bucket name
* `S3_FOLDER_NAME` - Objects folder (prefix) without ending slash
* `S3_CHUNK_SIZE` - Chunk size in MB (be careful, chunks count is limited to 1000 on *Scaleway Object storage*)
* `S3_STORAGE_CLASS` - Default: `STANDARD` - Stores object with specified CLASS (`STANDARD`, `STANDARD_IA`, or `REDUCED_REDUNDANCY`) - For [scaleway.com](https://www.scaleway.com/en/docs/storage/object/quickstart/?_ga=2.254615240.1932398353.1675415614-917218686.1666605139#how-to-upload-files-into-a-bucket): 
  * `STANDARD`: The Standard class for any upload; suitable for on-demand content like streaming or CDN
  * `ONEZONE_IA`: The ONEZONE_IA class available only on FR-PAR is a good choice for storing secondary backup copies or easily re-creatable data.
  * `GLACIER`: Archived storage. Your data needs to be restored first to be accessed. This class is available in the FR-PAR and NL-AMS regions.
* `LOCAL_PATH` - Absolute path for folder to backup (default: `/var/www/html`)
* `COMPRESS` - (Optional) Default: `1`, compress files TAR archive
  
### Optional env vars to dump MySQL or PostgreSQL databases

* `DB_USER` - (Optional) MySQL user name
* `DB_HOST` - (Optional) MySQL host name
* `DB_PASS` - (Optional) MySQL user password
* `DB_NAME` - (Optional) MySQL name
* `PGDATABASE` - (Optional) PostgreSQL Database nam
* `PGHOST` - (Optional) PostgreSQL host name
* `PGOPTIONS` - (Optional) PostgreSQL options
* `PGPORT` - (Optional) PostgreSQL port
* `PGUSER` - (Optional) PostgreSQL user name
* `PGPASSWORD` - (Optional) PostgreSQL user password

Your PostgreSQL server version must match pg_dump: version 12.x max

## Launch backup

```shell
docker-compose run --rm backup
```

## Use s3cmd command

https://s3tools.org/usage

You can run any command instead of backup, for example listing your bucket files:

```shell
docker-compose run --rm backup s3cmd ls s3://mybucket/backups/
```

## How to delete backups files automatically?

Use *Lifecycle rules* or [Object Lifecycle Management](https://docs.aws.amazon.com/AmazonS3/latest/dev/object-lifecycle-mgmt.html) to define rules to expire or transfer your backup files to Glacier.

For example you can define an expiry policy based on your objects prefix: `${S3_FOLDER_NAME}/` which is `backups/`.

## Usage in docker-compose environment

```yaml
  backup:
    image: ambroisemaupate/s3-backup
    networks:
      - default
    depends_on:
      - db
    environment:
      LOCAL_PATH: /var/www/html
      # Use MySQL
      DB_USER: ${MYSQL_USER}
      DB_HOST: db
      DB_PASS: ${MYSQL_PASSWORD}
      DB_NAME: ${MYSQL_DATABASE}
      # Or use PostgreSQL
      # PGDATABASE: ${PGDATABASE}
      # PGHOST: db
      # PGUSER: ${PGUSER}
      # PGPASSWORD: ${PGPASSWORD}
      S3_ACCESS_KEY: xxxxxxxxx
      S3_SECRET_KEY: xxxxxxxxx
      S3_SIGNATURE: s3v4
      S3_BUCKET_LOCATION: fr-par
      S3_HOST_BASE: https://s3.fr-par.scw.cloud
      S3_HOST_BUCKET: https://mybucket.s3.fr-par.scw.cloud
      S3_BUCKET_NAME: mybucket
      S3_FOLDER_NAME: site-backups
      S3_STORAGE_CLASS: STANDARD
    volumes:
      - public_files:/var/www/html/web/files:ro
```

Then execute it manually:

```shell
docker-compose run --rm --no-deps backup
```
Or from your *crontab*:
```
00 0 * * * cd /root/docker-server-env/compose/my_site && /usr/local/bin/docker-compose run --no-deps --rm backup
```

## Dev

- Copy `.env.dist` to `.env`
- Use `docker-compose.yml` to test locally
- Launch backup `docker-compose run --rm backup`
