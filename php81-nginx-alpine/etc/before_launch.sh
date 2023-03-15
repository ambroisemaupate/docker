# Fix volume permissions
/bin/chown -R www-data:www-data /var/www/html/files;
/bin/chown -R www-data:www-data /var/www/html/web;
/bin/chown -R www-data:www-data /var/www/html/app;
# Symfony directories
/bin/chown -R www-data:www-data /var/www/html/public;
/bin/chown -R www-data:www-data /var/www/html/config;
/bin/chown -R www-data:www-data /var/www/html/var;
