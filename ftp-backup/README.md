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
* `DB_USER` - (Optional) Database user name
* `DB_HOST` - (Optional) Database host name
* `DB_PASS` - (Optional) Database user password
* `DB_NAME` - (Optional) Database name

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
           --link my-mariadb:mariadb ambroisemaupate/ftp-backup
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
      REMOTE_PATH: /home/test/backups
    volumes:
      - public_files:/var/www/html/web/files:ro

volumes:
  public_files:
  DBDATA:
```
