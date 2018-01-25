# nginx-php56

Based on `ambroisemaupate/nginx`.
Adding PHP5.6 support using dotdeb.org repository.

**Be careful**, PHP is configured with **OPCache** and a very aggressive PHP class cache: `opcache.revalidate_freq=60`.
If you are modifying some php files directly on your container, *restart your container*
or add `fastcgi_param PHP_VALUE "opcache.revalidate_freq=0";` line in your fastcgi Nginx config.

## Available extensions

- php5-cli
- php5-curl
- php5-json
- php5-fpm
- php5-gd
- php5-mcrypt
- php5-zip
- php5-opcache
- php5-intl
- php5-imap
- php5-pspell
- php5-recode
- php5-tidy
- php5-xmlrpc
- php5-xsl
- php5-apcu
- php5-mysql
- php5-pgsql
- php5-sqlite3
- php5-mbstring
- php5-imagick