FROM centos:centos6

MAINTAINER Sergio Bruder <sergio@bruder.com.br>

RUN	rpm -Uvh \
		http://www.percona.com/downloads/percona-release/percona-release-0.0-1.x86_64.rpm \
		http://mirror.webtatic.com/yum/el6/latest.rpm && \
	yum install -y \
		--setopt=override_install_langs=en \
		--setopt=tsflags=nodocs \
		python-setuptools nginx16 php55w-fpm php55w-intl php55w-mcrypt php55w-opcache \
		php55w-mysqlnd Percona-Server-server-56 Percona-Server-client-56 && \
	easy_install supervisor && \
	service mysql start && \
	echo "GRANT ALL ON *.* TO 'root'@'%';" | mysql mysql && \
	service mysql stop && \
	yum clean all && \
	rm -f /var/lib/mysql/ib* && \
	find /var/log/ -type f -exec rm \{\} \;

RUN mkdir -p /opt/webapp

EXPOSE  80
EXPOSE  3306

ADD conf/supervisord.conf /etc/supervisord.conf
ADD conf/nginx.conf       /etc/nginx/nginx.conf
ADD conf/my.cnf           /etc/my.cnf
ADD conf/php.ini          /etc/php.ini
ADD conf/index.php        /opt/webapp/index.php

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
