# nginx-php

Based on `ambroisemaupate/nginx`.
Adding PHP7 support using dotdeb.org repository.

```
PHP 7.1.6-2+0~20170614060700.1+jessie~1.gbp831871 (cli) (built: Jun 14 2017 06:28:54) ( NTS )
Copyright (c) 1997-2017 The PHP Group
Zend Engine v3.1.0, Copyright (c) 1998-2017 Zend Technologies
    with Zend OPcache v7.1.6-2+0~20170614060700.1+jessie~1.gbp831871, Copyright (c) 1999-2017, by Zend Technologies
```

**Be careful**, PHP is configured with **OPCache** and a very aggressive PHP class cache: `opcache.revalidate_freq=60`.
If you are modifying some php files directly on your container, *restart your container*
or add `fastcgi_param PHP_VALUE "opcache.revalidate_freq=0";` line in your fastcgi Nginx config.

## Available extensions

- php7.1-cli
- php7.1-curl
- php7.1-json
- php7.1-fpm
- php7.1-gd
- php7.1-mcrypt
- php7.1-zip
- php7.1-opcache
- php7.1-intl
- php7.1-imap
- php7.1-pspell
- php7.1-recode
- php7.1-tidy
- php7.1-xmlrpc
- php7.1-xsl
- php7.1-apcu
- php7.1-apcu-bc
- php7.1-mysql
- php7.1-pgsql
- php7.1-sqlite3
- php7.1-mbstring
- php7.1-imagick