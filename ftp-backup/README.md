# FTP backup

Backup a data-oriented container and a MariaDB/MySQL container and
upload them to a FTP/SFTP server using `lftp`.

This script will archive your `/data` (or custom) folder and use `mysqldump` to
backup your database.

## ENV variables

* `FTP_USER` - FTP server username
* `FTP_PASS` - FTP server user password
* `FTP_HOST` - FTP server hostname
* `FTP_PORT` - FTP server port
* `FTP_PROTO` - Protocol to use (default: ftp)
* `LOCAL_PATH` - Absolute path for folder to backup (default: `/data`)
* `REMOTE_PATH` - Your FTP backup destination folder
  
### Optional env vars to control archiving and FTP upload

* `COMPRESS` - (Optional) Default: `1`, compress files TAR archive
* `CHUNK_SIZE` - (Optional) Default: `0`, in mega Bytes, splits TAR archive into parts for better FTP upload with very large archives
* `PARALLEL_UPLOADS` - (Optional) Default: `3`, *only for split archives*, max parallel uploads at the same time

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

## Usage

```shell
docker run --rm -t --name="backup1" -v my-data-volume:/data:ro \
           -e DB_USER="toto" \
           -e DB_HOST="mariadb" \
           -e DB_PASS="123abc" \
           -e DB_NAME="foo_db" \
           -e FTP_USER="username" \
           -e FTP_PASS="butterfly" \
           -e FTP_HOST="foobar.com" \
           -e FTP_PORT="21" \
           -e REMOTE_PATH="/backups/my-site" \
           -e COMPRESS="0" \
           -e CHUNK_SIZE="128" \
           --link my-mariadb:mariadb ambroisemaupate/ftp-backup
```

### Do not compress when not necessary 
If your folder to backup contains mostly JPG, PNG, WebP images (or any already compressed data), **do not compress** archive as it will use
lots of CPU for a little less space: `COMPRESS=0`. 

### Split for weak FTP servers
Splitting archives before uploading can enhance stability and allow transfers to resume if you disconnected from FTP server : `CHUNK_SIZE=128`.
`split` command will generate *.partaa to *.partzz files in order to keep them in order and easily allow `cat` to join them back. 

If you need to recover archive from a split file, use: 

```bash
cat 20210727_0904_files/20210727_0904_files.tar.part* >> 20210727_0904_files.tar
```

## How to automatize backups

I use a simple bash script to automatize docker backups along a ftp-credential.sh
script to store FTP access data once for all.

I variabilized docker name to generate automatically container names.
I use the following naming policy:

* Main worker container is called `NAME`
* Database worker container is called after `NAME` + `_DB` suffix
* Main *data* container is called after `NAME` + `_DATA` suffix
* Database *data* container is called after `NAME` + `_DBDATA` suffix
* Main *back-up* container is called after `NAME` + `_BCK` suffix

```shell
#!/usr/bin/env bash
# Author: Ambroise Maupate
# File: /root/scripts/bck-my-docker-container.sh

. `dirname $0`/ftp-credentials.sh || {
    echo "`dirname $0`/ftp-credentials.sh";
    echo 'Impossible to import your ftp config.';
    exit 1;
}

NAME="my-docker-container"

docker run --rm -t --name="${NAME}_BCK" -v ${NAME}_DATA:/data:ro \
           -e FTP_USER="${FTP_USER}"\
           -e FTP_PASS="${FTP_PASS}"\
           -e FTP_HOST="${FTP_HOST}"\
           -e FTP_PORT="${FTP_PORT}"\
           -e DB_USER="my_docker_container_dbuser"\
           -e DB_HOST="mariadb"\
           -e DB_PASS="my_docker_container_dbpass"\
           -e DB_NAME="my_docker_container_db"\
           -e REMOTE_PATH="/docker-bck/${NAME}"\
           --link ${NAME}_DB:mariadb ambroisemaupate/ftp-backup

```

Here is the central ftp access data script.

```shell
#!/usr/bin/env bash
# Author: Ambroise Maupate
# File: /root/scripts/ftp-credentials.sh

FTP_USER="myFtpUser"
FTP_PASS="myFtpPassword"
FTP_HOST="myFtp.host.com"
FTP_PORT="21"
```

Then all you need is to setup this in your root’s `crontab`:

```shell
0 2 * * * /bin/bash ~/scripts/bck-my-docker-container.sh >> bcklog-my-docker-container.log
```

And do not forget to set executable flag on your scripts:

```shell
chmod u+x ~/scripts/ftp-credentials.sh
chmod u+x ~/scripts/bck-my-docker-container.sh
```

## Use SFTP protocol

Add `FTP_PORT` and `FTP_PROTO` environment vars.

```shell
docker run --rm -t --name="backup1" -v my-data-volume:/data:ro \
           -e DB_USER="toto" \
           -e DB_HOST="mariadb" \
           -e DB_PASS="123abc" \
           -e DB_NAME="foo_db" \
           -e FTP_USER="username" \
           -e FTP_PASS="butterfly" \
           -e FTP_HOST="foobar.com" \
           -e FTP_PORT="22" \
           -e FTP_PROTO="sftp" \
           -e CHUNK_SIZE="512" \
           -e REMOTE_PATH="/home/username/backups/my-site" \
           --link my-mariadb:mariadb ambroisemaupate/ftp-backup
```

## Example usage in *docker-compose*

```yaml
version: "3"
services:
  db:
    image: mysql:5.7
    volumes:
      - DBDATA:/var/lib/mysql
    environment:
      MYSQL_DATABASE: test
      MYSQL_USER: test
      MYSQL_PASSWORD: test
      MYSQL_RANDOM_ROOT_PASSWORD: "yes"
    restart: always

  backup:
    image: ambroisemaupate/ftp-backup
    depends_on:
      - db
    environment:
      LOCAL_PATH: /var/www/html
      DB_USER: test
      DB_HOST: db
      DB_PASS: test
      DB_NAME: test
      FTP_PROTO: ftp
      FTP_PORT: 21
      FTP_HOST: ftp.server.test
      FTP_USER: test
      FTP_PASS: test
      CHUNK_SIZE: 512
      REMOTE_PATH: /home/test/backups
    volumes:
      - public_files:/var/www/html/web/files:ro

volumes:
  public_files:
  DBDATA:
```

## Rolling backups

You can add as much services as you want to create rolling backups: daily, weekly, monthly: 

```yaml
  # DAILY
  backup_daily:
    image: ambroisemaupate/ftp-backup
    depends_on:
      - db
    environment:
      LOCAL_PATH: /var/www/html
      DB_USER: test
      DB_HOST: db
      DB_PASS: test
      DB_NAME: test
      FTP_PROTO: ftp
      FTP_PORT: 21
      FTP_HOST: ftp.server.test
      FTP_USER: test
      FTP_PASS: test
      REMOTE_PATH: /home/test/backups/daily
    volumes:
      - public_files:/var/www/html/web/files:ro

  backup_cleanup_daily:
    image: ambroisemaupate/ftp-cleanup
    environment:
      FTP_PROTO: ftp
      FTP_PORT: 21
      FTP_HOST: ftp.server.test
      FTP_USER: test
      FTP_PASS: test
      STORE_DAYS: 7
      FTP_PATH: /home/test/backups/daily
  
  # WEEKLY
  backup_weekly:
    image: ambroisemaupate/ftp-backup
    depends_on:
      - db
    environment:
      LOCAL_PATH: /var/www/html
      DB_USER: test
      DB_HOST: db
      DB_PASS: test
      DB_NAME: test
      FTP_PROTO: ftp
      FTP_PORT: 21
      FTP_HOST: ftp.server.test
      FTP_USER: test
      FTP_PASS: test
      REMOTE_PATH: /home/test/backups/weekly
    volumes:
      - public_files:/var/www/html/web/files:ro

  backup_cleanup_weekly:
    image: ambroisemaupate/ftp-cleanup
    environment:
      FTP_PROTO: ftp
      FTP_PORT: 21
      FTP_HOST: ftp.server.test
      FTP_USER: test
      FTP_PASS: test
      STORE_DAYS: 30
      FTP_PATH: /home/test/backups/weekly
  
  # MONTHLY
  backup_monthly:
    image: ambroisemaupate/ftp-backup
    depends_on:
      - db
    environment:
      LOCAL_PATH: /var/www/html
      DB_USER: test
      DB_HOST: db
      DB_PASS: test
      DB_NAME: test
      FTP_PROTO: ftp
      FTP_PORT: 21
      FTP_HOST: ftp.server.test
      FTP_USER: test
      FTP_PASS: test
      REMOTE_PATH: /home/test/backups/monthly
    volumes:
      - public_files:/var/www/html/web/files:ro

  backup_cleanup_monthly:
    image: ambroisemaupate/ftp-cleanup
    environment:
      FTP_PROTO: ftp
      FTP_PORT: 21
      FTP_HOST: ftp.server.test
      FTP_USER: test
      FTP_PASS: test
      STORE_DAYS: 366
      FTP_PATH: /home/test/backups/monthly
```

then launch them once a day, once a week, once a month from your crontab:

```shell
# Rolling backups (do not use same hour of night to save CPU)
# Daily
00 2 * * * cd /mywebsite.com && /usr/local/bin/docker-compose run --rm --no-deps backup_daily
20 2 * * * cd /mywebsite.com && /usr/local/bin/docker-compose run --rm --no-deps backup_cleanup_daily
# Weekly
00 3 * * 1 cd /mywebsite.com && /usr/local/bin/docker-compose run --rm --no-deps backup_weekly
20 3 * * 1 cd /mywebsite.com && /usr/local/bin/docker-compose run --rm --no-deps backup_cleanup_weekly
# Monthly
00 4 1 * * cd /mywebsite.com && /usr/local/bin/docker-compose run --rm --no-deps backup_monthly
20 4 1 * * cd /mywebsite.com && /usr/local/bin/docker-compose run --rm --no-deps backup_cleanup_monthly
```
