# _Restic_ example usage in docker-compose environment

[Basic example](./docker-compose.yml) using restic to back up a volume to a s3 bucket:

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

## How to delete backups files automatically with cron?

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
docker compose run --rm restore
```
