# roadiz/nginx-alpine

Nginx image for _Roadiz_ / _Symfony_ / _API Platform_ projects. With additional mime types.

- Server root is located at `/var/www/html/public`.
- PHP-FPM must be available at `app:9000`.
- Nginx running user UID and GID are set to `1000` by default to match your PHP-FPM user UID and GID. You can customize `nginx_uid` and `nginx_gid` build arguments to match your needs.
