# FTP backup

Backup a data-oriented container and a MariaDB/MySQL container and
upload them to a FTP server using `lftp`.

This script will archive your `/data` folder and use `mysqldump` to
backup your database.

## ENV variables

* `FTP_USER` - FTP server username
* `FTP_PASS` - FTP server user password
* `FTP_HOST` - FTP server hostname
* `FTP_PORT` - FTP server port
* `REMOTE_PATH` - Your FTP backup destination folder
* `DB_USER` - (Optional) Database user name
* `DB_HOST` - (Optional) Database host name
* `DB_PASS` - (Optional) Database user password
* `DB_NAME` - (Optional) Database name

## Usage

```shell
docker run --rm -t --name="backup1" --volumes-from my-data-volume:ro \
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
