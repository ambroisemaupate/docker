FROM ambroisemaupate/nginx:latest
MAINTAINER Ambroise Maupate <ambroise@rezo-zero.com>
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E9C74FEEA2098A6E && \
	echo "deb http://packages.dotdeb.org/ jessie all" > /etc/apt/sources.list.d/php.list && \
	apt-get update && \
	apt-get install -y php7.0-cli php7.0-curl php7.0-fpm php7.0-gd php7.0-mcrypt php7.0-zip \
                       php7.0-opcache php7.0-intl php7.0-imap php7.0-pspell php7.0-recode \
                       php7.0-tidy php7.0-xmlrpc php7.0-xsl php7.0-apcu php7.0-apcu-bc \
                       php7.0-mysql php7.0-pgsql php7.0-sqlite3 php7.0-mbstring php7.0-imagick && \
	apt-get clean && \
	echo -n > /var/lib/apt/extended_states
RUN rm -rf /etc/nginx/addon.d /etc/php/7.0/fpm/pool.d && \
	mkdir -p /etc/nginx/addon.d /etc/php/7.0/fpm/pool.d
ADD etc /etc
RUN phpenmod tuning
ADD supervisord.conf /etc/supervisor/conf.d/php-fpm.conf
