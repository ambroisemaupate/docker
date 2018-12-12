# Fix volume permissions
exec chown -R www-data:www-data /var/www/html/files
exec chown -R www-data:www-data /var/www/html/web
exec chown -R www-data:www-data /var/www/html/app