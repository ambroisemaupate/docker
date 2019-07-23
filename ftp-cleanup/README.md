# FTP cleanup

Clean-up FTP files older than X days…

*Based on [hatifnatt/removeOlderThanDays.sh](https://gist.github.com/hatifnatt/be0fe64f19244f03180c) script.*

**Be careful, if not well configured this image can remove all files in your
FTP account!**

Make sur to pass the `FTP_PATH` environment variable to scope all operations
in a chosen folder.

## Usage

```
docker run --rm -c=256 \
                -e FTP_PATH="/my/backup/dir" \
                -e FTP_HOST="myhost.com" \
                -e FTP_USER="user" \
                -e FTP_PASS="password" \
                -e FTP_PORT="21" \
                -e FTP_PROTO="ftp" \
                -e STORE_DAYS="5" \
                ambroisemaupate/ftp-clean;
```

### or in a compose

```yaml
version: "3"
services:
    backup_cleanup:
        image: ambroisemaupate/ftp-cleanup
        environment:
            FTP_PROTO: ftp
            FTP_PORT: 21
            FTP_HOST: "ftp.server.test"
            FTP_USER: "test"
            FTP_PASS: "test"
            STORE_DAYS: 5
            FTP_PATH: "/home/test/backups"
```