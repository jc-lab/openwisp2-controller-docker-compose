FROM solita/ubuntu-systemd:18.04
MAINTAINER jichan <development@jc-lab.net>

RUN apt-get update
RUN apt-get install -y git curl python3 python3-pip python python-openssl python-pip virtualenv gdal-bin libgdal20 python-gdal libmysqlclient20 libmysqlclient-dev software-properties-common python3-openssl ca-certificates gcc make libffi-dev libcurl4-openssl-dev sshpass openssh-server
RUN pip3 install ansible
RUN ansible-galaxy install openwisp.openwisp2
RUN mkdir /var/run/sshd
RUN echo 'root:wti1ab10zn' | chpasswd
RUN sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
RUN systemctl enable ssh
RUN mkdir /defaultconfig
RUN cp -rf /etc/ssh /defaultconfig/ssh
RUN mkdir /root/.ssh
RUN echo "#!/bin/bash" > /etc/rc.local
RUN echo "/defaultconfig.sh > /var/log/defaultconfig.log 2>&1 & " >> /etc/rc.local
RUN chmod +x /etc/rc.local
RUN sed -ri 's/After=network.target//g' /lib/systemd/system/rc-local.service
RUN systemctl enable rc-local.service
COPY defaultconfig.sh /defaultconfig.sh

