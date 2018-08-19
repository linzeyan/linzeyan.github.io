#!/bin/bash

Ansible_host='/home/Git_repository/ansible/hosts'
cp $Ansible_host /tmp/host
PRE=`cat /tmp/host|grep 'ansible_ssh_host'|sed 's/ansible_ssh_host=//'|sed 's/ansible_ssh_port=//'|
awk '{if ($3 != "") print $3":"$2,$1; else if ($2 != "") print $2,$1;}' > /tmp/tmp.txt`
cat >> /tmp/tmp.txt << EOF
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
EOF
rm -f /tmp/host /etc/hosts
cp /tmp/tmp.txt /etc/hosts
rm -f /tmp/tmp.txt
