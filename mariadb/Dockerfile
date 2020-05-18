FROM ambroisemaupate/debian:latest
MAINTAINER Ambroise Maupate <ambroise@rezo-zero.com>

ENV MARIADB_USER=docker
ENV MARIADB_PASS=docker

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys CBCB082A1BB943DB && \
	echo "deb http://ftp.osuosl.org/pub/mariadb/repo/10.2/debian/ jessie main" > /etc/apt/sources.list.d/mariadb.list && \
	apt-get update && \
	apt-get install -y mariadb-server && \
	apt-get clean && \
	echo -n > /var/lib/apt/extended_states && \
	rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*
RUN sed -i -e "s/^bind-address/#bind-address/" /etc/mysql/my.cnf && \
	sed -i -e "s/^datadir.*=.*/datadir = \/data/" /etc/mysql/my.cnf && \
	sed -i -e "s/^user.*=.*/user = core/" /etc/mysql/my.cnf && \
	sed -i -e "s/\/var\/log\/mysql/\/data\/log/" /etc/mysql/my.cnf && \
	touch /var/log/mysql.err && \
	touch /var/log/mysql.log && \
	chown -R core:adm /var/log/mysql.err && \
	chown -R core:adm /var/log/mysql.log && \
	chown -R core:adm /var/log/mysql

ADD config /config
ADD supervisord.conf /etc/supervisor/conf.d/mariadb.conf
EXPOSE 3306
