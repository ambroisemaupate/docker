# Light SSH

***Deprecated*** and not maintained anymore. Do not expose it on a network.

- Its base image `luzifer/sftp-share` no longer exists, so it cannot be rebuilt.
- It ships an end-of-life Alpine 3.13 with OpenSSH 8.4 (musl, without PAM), with password
  authentication and root login enabled: see [sshole](https://sshhole.com/).
- `start.sh` hashes the user password with DES `crypt()`: only its first 8 characters count.

Use `docker exec` or `docker compose exec` to run Composer, Git or PHP CLI in your containers instead.

This image is useful if you need to allow your users to access their own containers using SSH connection
to be able to use *Composer*, *Git* and *PHP* cli utils. It can be useful for *Roadiz* or *Symfony2* apps.

## Available commands

- git
- zip
- php
- composer
- mysql
- nano

## Usage

Light SSH already set environment vars `USER=core` and `UID=500` for *maxexcloo* images compatibility.

```shell
# Light SSH already set USER=core and UID=500 for maxexcloo/data compatibility
docker run -d --name test_SSH -e PASS=test -v test_DATA:/data -p 22 ambroisemaupate/light-ssh
```