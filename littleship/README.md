LittleShip docker image
=======================

This image is almost based on *ambroisemaupate/nginx-php* image, it only adds
the `core` user to the `docker` group (gid 999) to be able to access `/var/run/docker.sock`.

Just verify that your host `docker` group has `999` *gid*. If not, change it inside your
littleship container to reflect the same *gid* as your host.

```shell
# Create a data container
docker run --name littleship_data ambroisemaupate/data;

# Create the main container, you must attach it for the first time
# as Symfony will ask you some parameters.
docker run -ti --name littleship --volumes-from littleship_data \
           -v /var/run/docker.sock:/var/run/docker.sock \
           -e VIRTUAL_HOST=littleship.mydomain.com ambroisemaupate/littleship;
```

### Install symfony and assets

By default this image installs *LittleShip* with symfony standard edition.
It installs *Grunt* and *Bower* for front dependencies. Once *Symfony* is correctly
setup with its database, you should do:

```shell
su core;
cd /data/http;
app/console assets:install --symlink && grunt deploy;
```