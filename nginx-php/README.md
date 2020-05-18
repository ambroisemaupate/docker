# ambroisemaupate/nginx-php

***Deprecated*** and not maintained anymore.

Based on `ambroisemaupate/nginx`.
Adding PHP7 support using dotdeb.org repository.

```
PHP 7.2.6-2+0~20170614060700.1+jessie~1.gbp831871 (cli) (built: Jun 14 2017 06:28:54) ( NTS )
Copyright (c) 1997-2017 The PHP Group
Zend Engine v3.1.0, Copyright (c) 1998-2017 Zend Technologies
    with Zend OPcache v7.2.6-2+0~20170614060700.1+jessie~1.gbp831871, Copyright (c) 1999-2017, by Zend Technologies
```

**Be careful**, PHP is configured with **OPCache** and a very aggressive PHP class cache: `opcache.revalidate_freq=60`.
If you are modifying some php files directly on your container, *restart your container*
or add `fastcgi_param PHP_VALUE "opcache.revalidate_freq=0";` line in your fastcgi Nginx config.

## Available extensions

- php7.2-cli
- php7.2-curl
- php7.2-json
- php7.2-fpm
- php7.2-gd
- php7.2-mcrypt
- php7.2-zip
- php7.2-opcache
- php7.2-intl
- php7.2-imap
- php7.2-pspell
- php7.2-recode
- php7.2-tidy
- php7.2-xmlrpc
- php7.2-xsl
- php7.2-apcu
- php7.2-apcu-bc
- php7.2-mysql
- php7.2-pgsql
- php7.2-sqlite3
- php7.2-mbstring
- php7.2-imagick
