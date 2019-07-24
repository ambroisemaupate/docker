# Debian *Jessie* base image

Installs : 

- locales 
- curl 
- git 
- ca-certificates 
- cron 
- openssh-client 
- inotify-tools 
- nano 
- pwgen 
- supervisor 
- unrar 
- unzip 
- wget 
- logrotate

Creates a `core` user with UID: `500` and home directory located in `/data`.

## Add locales to your system

Edit `/etc/locale.gen` or use a shared volume with you Docker host
to list locales to enable.

`locale-gen` will be executed at each container restart during main *loop*.

For example create a `/etc/locale.gen` file with contents:

```
en_US ISO-8859-1
en_US.ISO-8859-15 ISO-8859-15
en_US.UTF-8 UTF-8

fr_FR ISO-8859-1
fr_FR.UTF-8 UTF-8
```

then execute `locale-gen` or restart your container to activate these locales 
on your system and in all your applications using *.po* or *.mo* files for localization.