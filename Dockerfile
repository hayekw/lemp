FROM centos:centos6

MAINTAINER Sergio Bruder <sergio@bruder.com.br>

# Update base image
RUN yum -y update && yum clean all

# CVE-2014-7169 is not on all mirrors, better install it directly
# RUN rpm -Uvh https://kojipkgs.fedoraproject.org//packages/bash/4.2.48/2.fc20/x86_64/bash-4.2.48-2.fc20.x86_64.rpm

# xmlstarlet is useful when modifying attributes/elements
# saxon can be used to execute configuration transformation using XSLT
# augeas is a great tool to edit any configuration files (XML too)
# bsdtar can be used to unpack zip files using pipes
RUN yum -y install java-1.8.0-openjdk-devel xmlstarlet saxon augeas bsdtar && yum clean all

RUN yum -y install tar

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
ADD webtar/cometchat.zip  /opt/webapp/cometchat.zip

RUN yum -y install unzip

RUN unzip /opt/webapp/cometchat.zip -d /opt/webapp/

RUN chkconfig nginx on
RUN chkconfig mysql on
RUN chkconfig php-fpm on

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]

# Update base image
RUN yum -y update && yum clean all
# Set the WILDFLY_VERSION env variable
ENV WILDFLY_VERSION 8.1.0.Final
RUN yum -y install tar
RUN yum install -y wget
RUN wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u20-b26/jdk-8u20-linux-x64.tar.gz"
RUN mv jdk-8u20-linux-x64.tar.gz /opt/ && tar xzf /opt/jdk-8u20-linux-x64.tar.gz -C /opt
RUN cd /opt/jdk1.8.0_20
RUN alternatives --install /usr/bin/java java /opt/jdk1.8.0_20/bin/java 1
RUN yum -y install java-1.8.0-openjdk-devel xmlstarlet saxon augeas bsdtar && yum clean all
# Create the wildfly user and group
RUN groupadd -r wildfly -g 433 && useradd -u 431 -r -g wildfly -d /opt/wildfly -s /sbin/nologin -c "WildFly user" wildfly
# Create directory to extract tar file to
RUN mkdir /opt/wildfly-$WILDFLY_VERSION
# Add the WildFly distribution to /opt, and make wildfly the owner of the extracted tar content
RUN cd /opt && curl http://download.jboss.org/wildfly/$WILDFLY_VERSION/wildfly-$WILDFLY_VERSION.tar.gz | tar zx && chown -R wildfly:wildfly /opt/wildfly-$WILDFLY_VERSION
# Make sure the distribution is available from a well-known place
RUN ln -s /opt/wildfly-$WILDFLY_VERSION /opt/wildfly && chown -R wildfly:wildfly /opt/wildfly
# Set the JBOSS_HOME env variable
ENV JBOSS_HOME /opt/wildfly
# Expose the ports we're interested in
EXPOSE 8080 9990
# Run everything below as the wildfly user
USER root
# Set the default command to run on boot
# This will boot WildFly in the standalone mode and bind to all interface
CMD ["/opt/wildfly/bin/standalone.sh", "-b", "0.0.0.0", "-bmanagement", "0.0.0.0"]

