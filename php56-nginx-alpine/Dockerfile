# nginx 1.30.7 from verified sources: the Alpine branch of this base image
# no longer ships security fixes (nginx2root CVEs). Paths are taken from the
# Alpine nginx package, whose binary is replaced in the final image.
FROM php:5.6-fpm-alpine AS nginx-build

ARG NGINX_VERSION=1.30.7
ARG NGINX_SHA256=2565b5c837050e958f70fb0f73c48e2bca4542ad349fd356f46fb0c72610bc6e

RUN apk add --no-cache nginx curl gcc make libc-dev linux-headers libressl-dev pcre-dev zlib-dev \
    && curl -fsSL -o /tmp/nginx.tar.gz https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
    && echo "${NGINX_SHA256}  /tmp/nginx.tar.gz" | sha256sum -c - \
    && mkdir -p /usr/src/nginx \
    && tar xzf /tmp/nginx.tar.gz -C /usr/src/nginx --strip 1 \
    && cd /usr/src/nginx \
    && ./configure \
        $(nginx -V 2>&1 | sed -n 's/^configure arguments: //p' | tr ' ' '\n' | grep -E '^--(prefix|user|group|[a-z-]+-path)=') \
        --with-threads \
        --with-file-aio \
        --with-pcre-jit \
        --with-http_ssl_module \
        --with-http_v2_module \
        --with-http_realip_module \
        --with-http_addition_module \
        --with-http_sub_module \
        --with-http_dav_module \
        --with-http_flv_module \
        --with-http_mp4_module \
        --with-http_gunzip_module \
        --with-http_gzip_static_module \
        --with-http_auth_request_module \
        --with-http_random_index_module \
        --with-http_secure_link_module \
        --with-http_slice_module \
        --with-http_stub_status_module \
    && make -j$(getconf _NPROCESSORS_ONLN)

FROM php:5.6-fpm-alpine
MAINTAINER Ambroise Maupate <ambroise@rezo-zero.com>

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
    && apk --no-cache update \
    && apk --no-cache upgrade \
    && apk add --no-cache --virtual \
        .build-deps \
        $PHPIZE_DEPS \
        gcc g++ make \
        autoconf \
    && apk add --no-cache \
        libmcrypt-dev \
        mariadb-client \
        curl \
        freetype libpng libjpeg-turbo freetype-dev libpng-dev libjpeg-turbo-dev \
        postgresql-dev \
        supervisor \
        bash \
        nginx \
        supervisor \
        pngquant jpegoptim \
        zip \
        icu-dev libxml2-dev \
        dcron wget rsync ca-certificates \
    && NPROC=$(getconf _NPROCESSORS_ONLN) \
    && docker-php-ext-install -j${NPROC} exif json mcrypt intl mbstring mysqli pdo pdo_mysql pdo_pgsql zip xml \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/ \
    && docker-php-ext-install -j${NPROC} gd \
    && pecl install apcu-4.0.11 \
    && docker-php-ext-enable --ini-name 05-opcache.ini opcache \
    && docker-php-ext-enable --ini-name 20-apcu.ini apcu \
    && docker-php-ext-enable --ini-name 20-mcrypt.ini mcrypt \
    && apk del --no-cache gcc g++ make freetype-dev libpng-dev libjpeg-turbo-dev .build-deps \
    # https://github.com/docker-library/php/issues/443
    && pecl update-channels \
    && rm -rf /tmp/pear ~/.pearrc

# PHP config
ADD etc/php/5.6/php.ini /usr/local/etc/php/php.ini
ADD etc/php/zz-docker.conf /usr/local/etc/php-fpm.d/zz-docker.conf
COPY --from=nginx-build /usr/src/nginx/objs/nginx /usr/sbin/nginx
ADD etc/nginx /etc/nginx
ADD etc/supervisord.ini /etc/supervisor.d/services.ini
# Add a chown script to clean UID on web root at
# each container restart
ADD etc/before_launch.ini /etc/supervisor.d/before_launch.ini
ADD etc/before_launch.sh /before_launch.sh

# Add in your inheriting image to following lines
# to add your application code into server path.
#COPY . /var/www/html/
#VOLUME /var/www/html/files /var/www/html/web/files /var/www/html/app/logs /var/www/html/app/conf /var/www/html/app/gen-src

EXPOSE 80

ENTRYPOINT exec /usr/bin/supervisord -n -c /etc/supervisord.conf
#ENTRYPOINT ["/usr/bin/supervisord", "--nodaemon", "--configuration", "/etc/supervisord.conf"]
#CMD "/usr/bin/supervisord"
