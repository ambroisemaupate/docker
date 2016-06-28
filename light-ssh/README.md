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

## Using with maxexcloo/data

Light SSH already set environment vars `USER=core` and `UID=500` for maxexcloo/data compatibility.

```shell
# Create a test data container
docker run --name test_DATA maxexcloo/data
# Light SSH already set USER=core and UID=500 for maxexcloo/data compatibility
docker run -d --name test_SSH -e PASS=test --volumes-from=test_DATA -p 22 ambroisemaupate/light-ssh
```