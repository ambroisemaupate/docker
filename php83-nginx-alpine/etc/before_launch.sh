# Fix volume permissions
/bin/chown -R www-data:www-data /var/www/html/public;
/bin/chown -R www-data:www-data /var/www/html/config;
/bin/chown -R www-data:www-data /var/www/html/var;
