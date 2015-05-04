LittleShip docker image
=======================

This image is almost based on *maxexcloo/nginx-php* image, it only adds
the `core` user to the `docker` group (gid 999) to be able to access `/var/run/docker.sock`.

Just verify that your host `docker` group has `999` *gid*. If not, change it inside your
littleship container to reflect the same *gid* as your host.

```shell
# Create a data container
docker run --name littleship_data maxexcloo/data;

# Create the main container, you must attach it for the first time
# as Symfony will ask you some parameters.
docker run -ti --name littleship --volumes_from littleship_data \
           -v /var/run/docker.sock:/var/run/docker.sock \
           -e VIRTUAL_HOST=littleship.mydomain.com ambroisemaupate/littleship;
```