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
* `LOCAL_PATH` - Absolute path for folder to backup (default: `/var/www/html`)
* `DB_USER` - (Optional) Database user name
* `DB_HOST` - (Optional) Database host name
* `DB_PASS` - (Optional) Database user password
* `DB_NAME` - (Optional) Database name
* `COMPRESS` - (Optional) Default: `1`, compress files TAR archive

## Launch backup

```shell
docker-compose run --rm backup
```

## Use s3cmd command

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
      DB_USER: ${MYSQL_USER}
      DB_HOST: db
      DB_PASS: ${MYSQL_PASSWORD}
      DB_NAME: ${MYSQL_DATABASE}
      S3_ACCESS_KEY: xxxxxxxxx
      S3_SECRET_KEY: xxxxxxxxx
      S3_SIGNATURE: s3v4
      S3_BUCKET_LOCATION: fr-par
      S3_HOST_BASE: https://s3.fr-par.scw.cloud
      S3_HOST_BUCKET: https://mybucket.s3.fr-par.scw.cloud
      S3_BUCKET_NAME: mybucket
      S3_FOLDER_NAME: site-backups
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
