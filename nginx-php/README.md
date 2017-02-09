# nginx-php

Based on `ambroisemaupate/nginx`.
Adding PHP7 support using dotdeb.org repository.

```
PHP 7.0.3-1~dotdeb+8.1 (cli) ( NTS )
Copyright (c) 1997-2016 The PHP Group
Zend Engine v3.0.0, Copyright (c) 1998-2016 Zend Technologies
    with Zend OPcache v7.0.6-dev, Copyright (c) 1999-2016, by Zend Technologies
```

**Be careful**, PHP is configured with **OPCache** and a very aggressive PHP class cache: `opcache.revalidate_freq=60`.
If you are modifying some php files directly on your container, *restart your container*
or add `fastcgi_param PHP_VALUE "opcache.revalidate_freq=0";` line in your fastcgi Nginx config.

## Available extensions

- php7.0-cli
- php7.0-curl
- php7.0-fpm
- php7.0-gd
- php7.0-mcrypt
- php7.0-zip
- php7.0-opcache
- php7.0-intl
- php7.0-imap
- php7.0-pspell
- php7.0-recode
- php7.0-tidy
- php7.0-xmlrpc
- php7.0-xsl
- php7.0-apcu
- php7.0-apcu-bc
- php7.0-mysql
- php7.0-pgsql
- php7.0-sqlite3
- php7.0-mbstring
- php7.0-imagick