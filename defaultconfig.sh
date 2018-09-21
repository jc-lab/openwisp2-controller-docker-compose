#!/bin/sh

MYHOSTNAME=$(cat /opt/work/hostname)

if [ -f /etc/ssh/sshd_config ]; then
	cp -rf /defaultconfig/ssh/* /etc/ssh/
fi

grep -q -F "$MYHOSTNAME $(cat /etc/ssh/ssh_host_rsa_key.pub)" /root/.ssh/known_hosts || echo "$MYHOSTNAME $(cat /etc/ssh/ssh_host_rsa_key.pub)" >> /root/.ssh/known_hosts
grep -q -F "127.0.0.1 $MYHOSTNAME" /etc/hosts || echo "127.0.0.1 $MYHOSTNAME" >> /etc/hosts

if [ ! -f /root/.ssh/id_rsa ]; then
	ssh-keygen -b 2048 -t rsa -f /root/.ssh/id_rsa -q -N ""
	cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys
fi

if [ ! -f /opt/work/hosts ]; then
cat << EOF > /opt/work/hosts
[openwisp2]
$MYHOSTNAME
EOF
fi

if [ ! -f /opt/openwisp.installed ]; then
	cd /opt/work
	ansible-playbook -i hosts playbook.yml -u root --become --extra-vars="ansible_ssh_private_key_file=/root/.ssh/id_rsa"
	rc=$?
	chmod +x /opt/work/openwisp2/env/bin/uwsgi
	systemctl start redis-server
	systemctl restart supervisor
	if [ "$rc" -eq "0" ]; then
		touch /opt/openwisp.installed
	fi
fi

exit 0

