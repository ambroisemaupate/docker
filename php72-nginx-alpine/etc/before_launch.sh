# Fix volume permissions
exec chown -R www-data:www-data /var/www/html/files;
exec chown -R www-data:www-data /var/www/html/web/files;
exec chown -R www-data:www-data /var/www/html/web/robots.txt;
exec chown -R www-data:www-data /var/www/html/web/index.php;
exec chown -R www-data:www-data /var/www/html/web/preview.php;
exec chown -R www-data:www-data /var/www/html/app;
