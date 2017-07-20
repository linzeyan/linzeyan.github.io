#!/bin/bash
# centos 6.8
#------------------------------------------------------------
# install nginx
#------------------------------------------------------------
sudo yum install -y --no-install-recommends \
  epel-release  \
  nginx
#------------------------------------------------------------
# service start and open 80 port
#------------------------------------------------------------
sudo /etc/init.d/nginx start
iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
/sbin/iptables -I INPUT -p tcp --dport 80 -j ACCEPT
