# Light SSH

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