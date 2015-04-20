# FTP backup

Backup a data-oriented container and a MariaDB/MySQL container and
upload them to a FTP server using `lftp`.

This script will archive your `/data` folder and use `mysqldump` to
backup your database.

## ENV variables

* `DB_USER` - Database user name
* `DB_HOST` - Database host name
* `DB_PASS` - Database user password
* `DB_NAME` - Database name
* `FTP_USER` - FTP server username
* `FTP_PASS` - FTP server user password
* `FTP_HOST` - FTP server hostname
* `FTP_PORT` - FTP server port
* `REMOTE_PATH` - Your FTP backup destination folder

## Usage

```shell
docker run --rm --name="backup1" --volumes-from="my-data-volume" \
           --env="DB_USER=toto" \
           --env="DB_HOST=mariadb" \
           --env="DB_PASS=123abc" \
           --env="DB_NAME=foo_db" \
           --env="FTP_USER=username" \
           --env="FTP_PASS=butterfly" \
           --env="FTP_HOST=foobar.com" \
           --env="FTP_PORT=21" \
           --env="REMOTE_PATH=/backups/my-site" \
           --link="my-mariadb:mariadb" ambroisemaupate/ftp-backup
```
