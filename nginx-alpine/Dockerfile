FROM nginx:alpine
MAINTAINER Ambroise Maupate <ambroise@rezo-zero.com>

ARG nginx_uid=1000
ARG nginx_gid=1000

RUN apk add -U shadow && usermod -u $nginx_uid -o nginx && groupmod -g $nginx_gid -o nginx

ADD etc/nginx /etc/nginx
