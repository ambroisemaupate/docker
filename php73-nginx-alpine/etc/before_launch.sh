# Fix volume permissions
exec /bin/chown -R www-data:www-data /var/www/html/files;
exec /bin/chown -R www-data:www-data /var/www/html/web/files;
exec /bin/chown -R www-data:www-data /var/www/html/web/robots.txt;
exec /bin/chown -R www-data:www-data /var/www/html/web/index.php;
exec /bin/chown -R www-data:www-data /var/www/html/web/preview.php;
exec /bin/chown -R www-data:www-data /var/www/html/app;
exec /bin/chown -R www-data:www-data /var/www/html/app/logs;
