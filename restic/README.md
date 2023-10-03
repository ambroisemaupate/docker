# _Restic_ example usage in docker-compose environment

[Restic](https://restic.readthedocs.io/en/latest/index.html) is an awesome backup tool that can back up 
to many different storage providers. Unlike `ambroisemaupate/s3-backup` image, this tool will benefit from
snapshotting and deduplication to save storage space and accelerate backup process.

## Minimal configuration

[Basic example](./docker-compose.yml) using Restic to back up a volume to a s3 bucket:

```dotenv
S3_STORAGE_CLASS=STANDARD
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
RESTIC_PASSWORD=
RESTIC_REPOSITORY=s3:https://s3.fr-par.scw.cloud/mybucket/restic-backups
```

Make sure to back up `RESTIC_PASSWORD` env var elsewhere than on your server. If you need to restore data into a 
new server.

## How to use it?

2 services are available which are conveniently named `backup` and `forget` to avoid write args in command line 
and in *crontab*. These are extensions of the `restic` service which is the main service, without any default command.

```shell
# Launch backup default command with args `-o s3.storage-class=${S3_STORAGE_CLASS} /example-folder`
docker compose run --rm backup

# Launch forget default command with args `-o s3.storage-class=${S3_STORAGE_CLASS} --keep-daily 7 --keep-monthly 12`
docker compose run --rm forget
```

Or you can directly call `restic` service with your own args:

```shell
docker compose run --rm restic snapshots
```

## How to create and delete backups files automatically with cron?

```shell
# Runs backup every day at 1am
0 1 * * * cd /path/to/compose && /usr/bin/docker compose run --rm backup
# Runs forget every day at 3am
0 3 * * * cd /path/to/compose && /usr/bin/docker compose run --rm forget
```

## How to restore data?

A service is available which is conveniently named `restore` to use volume as read-write, it will restore `latest` snapshot. **Be careful, 
this will overwrite your data in the target folder.**
Make sure to restore the same sub-folder as target to avoid recreating the sub-folder in the target folder.

```shell
docker compose -f docker-compose.restore.yml run --rm restore
```

**Do not include the `restore` service in your production `docker-compose.yml` file, as you would accidentally launch it when using `docker compose up -d` command.**
Just add it when you need to restore data then remove it from your `docker-compose.yml` file. Or use a separate `docker-compose.restore.yml` file like in the example above.

## How to backup a database?

You will need to use `ambroisemaupate/restic-database` [image](Dockerfile) to back up your database.

This image extends official `restic/restic` with a special entrypoint that will dump your database into `${MYSQL_DUMP_FILENAME|PG_DUMP_FILENAME}` file
before executing `restic` command. Then you can use `backup` command to back up the dump file with 
your own options.

### Configuration for MySQL

```yaml
services:
    backup_mysql:
        # Keep the same hostname for all Restic services
        hostname: restic-backup
        image: ambroisemaupate/restic-database
        environment:
            AWS_ACCESS_KEY_ID: ${AWS_ACCESS_KEY_ID}
            AWS_SECRET_ACCESS_KEY: ${AWS_SECRET_ACCESS_KEY}
            S3_STORAGE_CLASS: ${S3_STORAGE_CLASS}
            RESTIC_REPOSITORY: ${RESTIC_REPOSITORY}
            RESTIC_PASSWORD: ${RESTIC_PASSWORD}
            # Database credentials
            MYSQL_HOST: ${MYSQL_HOST}
            MYSQL_DATABASE: ${MYSQL_DATABASE}
            MYSQL_PASSWORD: ${MYSQL_PASSWORD}
            MYSQL_USER: ${MYSQL_USER}
            # Database dump filename
            MYSQL_DUMP_FILENAME: ${MYSQL_DUMP_FILENAME}
        volumes:
            - restic_cache:/root/.cache/restic
        depends_on:
            - ${MYSQL_HOST}
        # Override the default entrypoint to dump the database before backing it up
        command: 'backup -o s3.storage-class=${S3_STORAGE_CLASS} --tag db ${MYSQL_DUMP_FILENAME}'

volumes:
    restic_cache:
```

### Configuration for PostgreSQL

```yaml
services:
    backup_pgsql:
        # Keep the same hostname for all Restic services
        hostname: restic-backup
        build:
            context: ./
            dockerfile: Dockerfile
        environment:
            AWS_ACCESS_KEY_ID: ${AWS_ACCESS_KEY_ID}
            AWS_SECRET_ACCESS_KEY: ${AWS_SECRET_ACCESS_KEY}
            S3_STORAGE_CLASS: ${S3_STORAGE_CLASS}
            RESTIC_REPOSITORY: ${RESTIC_REPOSITORY}
            RESTIC_PASSWORD: ${RESTIC_PASSWORD}
            # Postgres credentials
            PG_HOST: ${PG_HOST}
            PG_DATABASE: ${PG_DATABASE}
            PG_PASSWORD: ${PG_PASSWORD}
            PG_USER: ${PG_USER}
            PG_DUMP_FILENAME: ${PG_DUMP_FILENAME}
        volumes:
            - restic_cache:/root/.cache/restic
        depends_on:
            - ${PG_HOST}
        # Override the default entrypoint to dump the database before backing it up
        command: 'backup -o s3.storage-class=${S3_STORAGE_CLASS} --tag db ${PG_DUMP_FILENAME}'

volumes:
    restic_cache:
```
