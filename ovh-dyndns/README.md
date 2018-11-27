# DynDNS update script for OVH domains

https://docs.ovh.com/fr/domains/utilisation-dynhost/

Check every 5 minutes you WAN IP and if changed call OVH entry-point to update
your DynDNS domain.

```
docker run -d --name="ovh-dyndns" \
    -e "HOST=mydynamicdomain.domain.com" \
    -e "LOGIN=mylogin" \
    -e "PASSWORD=mypassword" \
    ambroisemaupate/ovh-dyndns
```

## Docker-compose

```
version: "3"
services:
  crond:
    image: ambroisemaupate/ovh-dyndns
    environment:
      HOST: mydynamicdomain.domain.com
      LOGIN: mylogin
      PASSWORD: mypassword
    restart: always
```

## Customize external NS server

By default, we use Google DNS to check your current DynDNS IP, but you can choose an
other DNS overriding `NSSERVER` env var:

```
docker run -d --name="ovh-dyndns" \
    -e "HOST=mydynamicdomain.domain.com" \
    -e "LOGIN=mylogin" \
    -e "PASSWORD=mypassword" \
    -e "NSSERVER=192.168.1.1" \
    ambroisemaupate/ovh-dyndns
```