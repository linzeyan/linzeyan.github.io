#!/bin/bash

sudo yum install -y --no-install-recommends \
  epel-release  \
  nginx
  
sudo /etc/init.d/nginx start
iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
/sbin/iptables -I INPUT -p tcp --dport 80 -j ACCEPT
